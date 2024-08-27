clean:
  cargo clean

build:
  cargo build

hp:
  cargo run -- --help

run:
  cargo build
  RUST_LOG=debug cargo run -- init all

get-ph:
  $(echo ${TYPST_PACKAGE_CACHE_PATH}) && echo "cache ok" || echo "cache not set"

get-ca:
  $(echo ${TYPST_PACKAGE_PATH}) && echo "path ok" || echo "path not set"

get:
  just get-ca 2>/dev/null
  just get-ph 2>/dev/null

del:
  /bin/fish -c "set --erase TYPST_PACKAGE_CACHE_PATH"
  /bin/fish -c "set --erase TYPST_PACKAGE_PATH"

set:
  /bin/fish -c "set -Ux TYPST_PACKAGE_CACHE_PATH /home/zu/typst/cache"
  /bin/fish -c "set -Ux TYPST_PACKAGE_PATH /home/zu/typst/path"

check:
  rustfmt --check ./src/main.rs

tyenv:
  cargo build --release
  RUST_LOG=debug cargo run --release

prod:
  RUST_LOG=info cargo run --release

install:
  cargo build --release
  strip ./target/releazse/tyenv
  cargo install --path .

fmt:
   rustfmt --config-path . ./src/main.rs