FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y vim curl iputils-ping wget jq bc && \
    apt-get clean

RUN sh -c "$(curl -sSfL https://release.anza.xyz/v2.1.5/install)"
