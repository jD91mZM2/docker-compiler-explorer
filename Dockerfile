FROM ubuntu:18.04

# Update and install packages
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y curl git build-essential software-properties-common snap
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

WORKDIR /tmp

# Support different programming languages...
## Haskell
RUN apt-get install -y cabal-install ghc
## Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="$PATH:/root/.cargo/bin/"
RUN rustup show
## Go
### TODO: we need gccgo, not regular go
###RUN curl https://dl.google.com/go/go1.11.5.linux-amd64.tar.gz > go.tar.gz
###RUN tar -C /usr/local -xf go.tar.gz
###ENV PATH="$PATH:/usr/local/go/bin"
###RUN go version
## Zig
RUN curl https://ziglang.org/download/0.3.0/zig-linux-x86_64-0.3.0.tar.xz > zig.tar.xz
RUN tar -C /usr/local -xf zig.tar.xz
ENV PATH="$PATH:/usr/local/zig-linux-x86_64-0.3.0"
RUN zig version
## C
RUN apt-get install -y clang
## Misc
RUN apt-get install -y gfortran nasm ocaml

# Compile the compiler explorer
COPY compiler-explorer /root/compiler-explorer
WORKDIR /root/compiler-explorer
RUN make prereqs

# Patch language support
RUN sed -i "s/^\(compilers=\).*$/\1rustc/g" etc/config/rust.defaults.properties
RUN sed -i "s/^\(compilers=\).*$/\1zig/g" etc/config/zig.defaults.properties
RUN echo "compilers=go" >> etc/config/go.defaults.properties

# Run
## TODO: Figure out why Ctrl+C doesn't work
EXPOSE 80/tcp
CMD ["./app.js", "--port", "80"]
