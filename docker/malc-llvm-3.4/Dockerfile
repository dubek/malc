FROM ubuntu:14.04

RUN mkdir -p /malc && \
    apt-get update && \
    apt-get install -y llvm libstdc++-4.8-dev libgc-dev libreadline6-dev ruby && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /malc
