FROM kasmweb/kasmos-desktop:1.19.0-rolling-weekly

ARG UPSTREAM_DIGEST=unknown
LABEL org.opencontainers.image.base.digest=$UPSTREAM_DIGEST

USER root

# Install networking utilities, plus gvfs (smb://, sftp:// support in Files)
# and a couple extra apps (Kate, Konsole).
# wireshark-common's postinst asks (via debconf) whether non-root users may
# capture packets; pre-seed "yes" so the install stays non-interactive, then
# add kasm-user to the wireshark group so captures work without sudo in the GUI.
RUN export DEBIAN_FRONTEND=noninteractive && \
    echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections && \
    apt-get update && apt-get install -y \
    iputils-ping \
    mtr-tiny \
    traceroute \
    dnsutils \
    netcat-openbsd \
    net-tools \
    iproute2 \
    ncat \
    nmap \
    ncdu \
    tcpdump \
    socat \
    whois \
    telnet \
    iperf3 \
    rsync \
    ipcalc \
    wireshark \
    gvfs \
    gvfs-backends \
    gvfs-fuse \
    kate \
    konsole \
    && usermod -aG wireshark kasm-user \
    && rm -rf /var/lib/apt/lists/*

USER 1000
