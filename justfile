# @ ----------------
# @ typst pkg manager
# @ ----------------

clean:
  cargo clean

# fmt: clean
#   rustfmt --config-path . ./src/main.rs

# check: fmt
#   rustfmt --check ./src/main.rs

build: clean
  cargo build --release

strip: build
  strip ./target/release/typenv

run: strip
  RUST_LOG=debug cargo run --release

install: strip
  cargo install --path .

# @ ----------------
# @ git quick commit
# @ ----------------

status:
  git status

add:status
  git add .

commit: add
  git commit -m "quick commit"

push: commit
  git push

# @ ----------------
# @ typst pkg manager
# @ ----------------

ty-init:
  test -d ${PWD}/packages/.local && echo "dir local exist" || mkdir -pv ${PWD}/packages/.local
  test -d ${PWD}/packages/.cache && echo "dir cache exist" || mkdir -pv ${PWD}/packages/.cache

ty-clean:
  rm -rf ./packages

ty-move:
  cp -rpv ./packages/* ~/.local/share/typst/packages

# @ ----------------
# @ list make
# @ ----------------

ty-mkl:
  RUST_LOG=debug cargo run --release -- --bin "/bin/fish" --dict "c@'set -Ux TYPST_PACKAGE_PATH ${PWD}/packages/.local'" --quoted

ty-mkc:
  RUST_LOG=debug cargo run --release -- --bin "/bin/fish" --dict "c@'set -Ux TYPST_PACKAGE_CACHE_PATH ${PWD}/packages/.cache'" --quoted

ty-mkx:
  /bin/fish -c "just ty-mkl 2>| tail -2 | head -1 | cut -c 46-"
  /bin/fish -c "just ty-mkc 2>| tail -2 | head -1 | cut -c 46-"

ty-mk:
  just ty-mkx 2>/dev/null

# @ ----------------
# @ list remover
# @ ----------------

ty-rml:
  RUST_LOG=debug cargo run --release -- --bin "/bin/fish" --dict "c@'set --erase TYPST_PACKAGE_PATH'" --quoted

ty-rmc:
  RUST_LOG=debug cargo run --release -- --bin "/bin/fish" --dict "c@'set --erase TYPST_PACKAGE_CACHE_PATH'" --quoted

ty-rmx:
  /bin/fish -c "just ty-rml 2>| tail -2 | head -1 | cut -c 46-"
  /bin/fish -c "just ty-rmc 2>| tail -2 | head -1 | cut -c 46-"

ty-rm:
  just ty-rmx 2>/dev/null

# @ ----------------
# @ list shower
# @ ----------------

ty-shc:
  RUST_LOG=debug cargo run --release -- --bin "/bin/fish" --dict "c@'echo ${TYPST_PACKAGE_CACHE_PATH}'" --quoted

ty-shl:
  RUST_LOG=debug cargo run --release -- --bin "/bin/fish" --dict "c@'echo ${TYPST_PACKAGE_CACHE_PATH}'" --quoted 1>/dev/null | cat - | tail -1 | cut -c 53-

ty-shx:
  /bin/fish -c "just ty-shl 2>| tail -2 | head -1 | cut -c 53-"
  /bin/fish -c "just ty-shc 2>| tail -2 | head -1 | cut -c 53-"

ty-sh:
  just ty-shx 2>/dev/null