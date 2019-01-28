FROM ubuntu:18.04

# Update and install packages
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y curl git build-essential software-properties-common snap
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs


# Support different programming languages...
## Haskell
RUN apt-get install -y cabal-install ghc
## Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
## Zig
#RUN snap install zig --classic --beta
## C
RUN apt-get install -y clang
## Misc
RUN apt-get install -y gfortran nasm ocaml

# Prepare compiler-explorer
COPY compiler-explorer compiler-explorer
WORKDIR compiler-explorer
RUN sed -i "s/^port=.*$/port=80/g" etc/config/compiler-explorer.defaults.properties
RUN npm install -g yarn
RUN yarn install

# Run
EXPOSE 80/tcp
CMD ["make"]
