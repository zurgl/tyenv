static ERROR_PROCESS_ON_EXEC: &'static str = "ERROR_PROCESS_ON_EXEC";
static ERROR_DICT_PARSING_FAIL: &'static str = "ERROR_DICT_PARSING_FAIL";
static ERROR_FAIL_TO_PARSE_CLI_ARGS: &'static str = "ERROR_FAIL_TO_PARSE_CLI_ARGS";
static ERROR_COMMAND_FAIL_TO_LAUNCH: &'static str = "ERROR_COMMAND_FAIL_TO_LAUNCH";

#[derive(clap::Parser, Debug)]
#[command(version, about, long_about = None)]
struct Cli {
    #[arg(short, long, default_value_t = String::from("/bin/fish"))]
    bin: String,

    #[arg(short, long, default_value_t = String::from("c@'set -Ux TYPST_PACKAGE_PATH /home/zu/typst/path'"))]
    dict: String,

    #[arg(short, long, long, default_value_t = true)]
    quoted: bool,
}

fn run_task(
    bin: &str,
    key: &str,
    value: &str,
    quoted: bool,
) -> std::result::Result<(), &'static str> {
    let key = format!("-{key}");
    let value = match quoted {
        true => format!("'{value}'"),
        _ => format!("{:?}\'", value),
    };

    log::info!("Formatted KEY: {key}");
    log::info!("Formatted VALUE: {value}");
    log::info!(
        "{}",
        format!("PROCESS: BIN: {bin} WITH(KEY: {key}, VALUE: {value}, IS_QUOTED: {quoted})")
    );

    match std::process::Command::new(bin).arg(&key).arg(&value).output() {
        Ok(stream) => {
            let status = stream.status.clone().to_string();
            match stream.status.success() {
                true => {
                    log::info!("{}", format!("PROCESS SUCCESS STATUS: {status}"));
                    log::info!(
                        "{}",
                        format!("PROCESS STDOUT: {}", String::from_utf8_lossy(&stream.stdout))
                    );

                    std::result::Result::Ok(())
                }
                false => {
                    log::error!("{}", format!("PROCESS ERROR STATUS: {status}"));
                    log::error!(
                        "{}",
                        format!("PROCESS STDERR: {:?}", String::from_utf8_lossy(&stream.stderr))
                    );
                    std::result::Result::Err(ERROR_PROCESS_ON_EXEC)
                }
            }
        }
        Err(error) => {
            log::error!("{}", format!("COMMAND ERROR: {:?}", error.to_string()));
            log::error!(
                "{}",
                format!("COMMAND ERROR SOURCE: {:?}", std::error::Error::source(&error))
            );
            std::result::Result::Err(ERROR_COMMAND_FAIL_TO_LAUNCH)
        }
    }
}

fn main() -> std::result::Result<(), &'static str> {
    env_logger::init();

    <Cli as clap::Parser>::try_parse()
        .map_err(|_| ERROR_FAIL_TO_PARSE_CLI_ARGS)
        .and_then(|Cli { bin, dict, quoted }| {
            log::info!("Brut Args: (bin:{:?}, dict:{:?}, quoted:{:?})", bin, dict, quoted);
            if let (Some(key), Some(value)) = dict.split_once("@").unzip() {
                run_task(&bin, key, value, quoted)
            } else {
                log::error!(
                    "{}",
                    format!("ARGS PRASED: BIN: {bin} DICT: {dict}, QUOTED: {quoted})")
                );
                std::result::Result::Err(ERROR_DICT_PARSING_FAIL)
            }
        })
        .and_then(|_| std::process::exit(0))
        .map_err(|err| {
            log::error!("EXIT ON ERROR: {err}");
            std::process::exit(1)
        })
}
