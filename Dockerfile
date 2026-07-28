FROM kasmweb/kasmos-desktop:1.19.0-rolling-weekly

USER root

# Install networking utilities
RUN apt-get update && apt-get install -y \
    iputils-ping \
    mtr-tiny \
    traceroute \
    dnsutils \
    netcat-openbsd \
    net-tools \
    iproute2 \
    && rm -rf /var/lib/apt/lists/*

USER 1000
