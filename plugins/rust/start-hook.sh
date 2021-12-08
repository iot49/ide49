#! /bin/bash

# install rust via rustup
# https://www.rust-lang.org/tools/install
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs >rustup.sh
chmod a+x rustup.sh
./rustup.sh -y
rm rustup.sh

# install jupyter kernel for rust
# https://github.com/google/evcxr/blob/main/evcxr_jupyter/README.md
rustup component add rust-src
cargo install evcxr_jupyter
evcxr_jupyter --install