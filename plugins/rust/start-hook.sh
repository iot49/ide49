#! /bin/bash

# install rust via rustup
# https://rustup.rs/
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -y

# install jupyter kernel for rust
# https://github.com/google/evcxr/blob/main/evcxr_jupyter/README.md
rustup component add rust-src
sudo apt install jupyter-notebook cmake build-essential
cargo install evcxr_jupyter
evcxr_jupyter --install