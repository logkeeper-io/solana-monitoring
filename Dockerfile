FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /root/solana/solana-monitoring/scripts

WORKDIR /root/solana/solana-monitoring/scripts

RUN apt-get update && \
    apt-get install -y vim curl iputils-ping wget jq bc gpg sudo&& \
    apt-get clean

RUN sh -c "$(curl -sSfL https://release.anza.xyz/v2.1.5/install)"

ENV PATH="$PATH:/root/.local/share/solana/install/active_release/bin/"



# Telegraf
RUN curl --silent --location -O \
    https://repos.influxdata.com/influxdata-archive.key \
    && echo "943666881a1b8d9b849b74caebf02d3465d6beb716510d86a39f6c8e8dac7515  influxdata-archive.key" \
    | sha256sum -c - && cat influxdata-archive.key \
    | gpg --dearmor \
    | tee /etc/apt/trusted.gpg.d/influxdata-archive.gpg > /dev/null \
    && echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' \
    | tee /etc/apt/sources.list.d/influxdata.list

RUN apt-get update && \
    apt-get install -y telegraf

COPY scripts/monitor.sh /root/solana/solana-monitoring/scripts/monitor.sh
COPY etc/telegraf.conf /etc/telegraf/telegraf.conf
