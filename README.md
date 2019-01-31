# Compiler Explorer in Docker

This is a self-hosted Docker image of [Compiler Explorer](https://github.com/mattgodbolt/compiler-explorer/).

## Why?

### Why docker?

Docker is a great fit for Compiler Explorer:

 - Can ship with a bunch of compilers pre-installed
 - All the ugly hacks needed to make certain things work can be reproducable
   easily

### Why not another docker image?

What does this image has to offer that most alternatives do not?

 - Supports C, C++, Fortran, Go, Haskell, OCaml, Rust and Zig.
 - Does some nginx hackiness to get the otherwise fairly bad (sorry Godbolt)
   custom path prefix to work using the build-time option `path_prefix`.
 - Doesn't run the main program as the root user.

# Screenshot

![Self hosted compiler explorer opened in http://localhost:8080/compiler-explorer](https://i.imgur.com/aDLrvjL.png)
