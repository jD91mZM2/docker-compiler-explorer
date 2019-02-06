FROM ubuntu:18.04

# Update and install general needed packages
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y curl git build-essential software-properties-common
## Node is installed from third-party so we can pin it at v8 in case a future
## version is incompatible.
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

WORKDIR /tmp

# Create non-root user to execute compiler explorer as
RUN groupadd users || true
RUN useradd -m -G users user

# Workarounds
## sudo and su work pretty bad with docker
RUN apt-get install -y gosu
## Fix Ctrl+C due to special handling of processes with PID 1.
## For an excellent explanation, read https://github.com/Yelp/dumb-init.
RUN apt-get install -y dumb-init

# Support different programming languages...
## Haskell
RUN apt-get install -y cabal-install ghc
## Rust (per-user)
USER user
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="$PATH:/home/user/.cargo/bin"
RUN rustup show
USER root
## Zig
RUN curl https://ziglang.org/download/0.3.0/zig-linux-x86_64-0.3.0.tar.xz > zig.tar.xz
RUN tar -C /usr/local -xf zig.tar.xz
ENV PATH="$PATH:/usr/local/zig-linux-x86_64-0.3.0"
RUN zig version
## Misc
RUN apt-get install -y clang gccgo gdc gfortran nasm ocaml

# Compile the compiler explorer
COPY --chown=user:users compiler-explorer /home/user/compiler-explorer
WORKDIR /home/user/compiler-explorer
USER user
RUN make prereqs
USER root
## Patch language support
RUN echo "compilers=gccgo" >> etc/config/go.defaults.properties
RUN sed -i "s|^\(compilers=\).*$|\1gdc|g" etc/config/d.defaults.properties
RUN sed -i "s|^\(demangler=\).*$|\1d/demangle|g" etc/config/d.defaults.properties
RUN sed -i "s|^\(compilers=\).*$|\1rustc|g" etc/config/rust.defaults.properties
RUN sed -i "s|^\(compilers=\).*$|\1zig|g" etc/config/zig.defaults.properties

# Path prefix
ARG path_prefix
RUN echo "httpRoot=/$path_prefix" >> etc/config/compiler-explorer.defaults.properties
## Install nginx to solve some issues
RUN apt-get install -y nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /var/www/index.html
RUN sed -i "s|/prefix|/$path_prefix|g" /etc/nginx/nginx.conf /var/www/index.html
RUN nginx -t

# Run
EXPOSE 80/tcp
ENTRYPOINT ["dumb-init", "--"]
CMD ["bash", "-c", "service nginx start && gosu user bash -c 'cd ~/compiler-explorer; ./app.js'"]
