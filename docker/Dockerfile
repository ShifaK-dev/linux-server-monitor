FROM ubuntu:26.04

RUN apt-get update && \
    apt-get install -y \
    bash \
    procps \
    iproute2 \
    iputils-ping \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY scripts/container_health.sh /app/container_health.sh

RUN chmod +x /app/container_health.sh

CMD ["/app/container_health.sh"]
