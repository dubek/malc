FROM ubuntu:22.04

# Install dependencies for building malc
RUN apt-get update && \
    apt-get install -y libreadline-dev libgc-dev llvm clang && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/malc
COPY . /opt/malc/
RUN cd /opt/malc && ./bootstrap.sh

ENV PATH="${PATH}:/opt/malc"
