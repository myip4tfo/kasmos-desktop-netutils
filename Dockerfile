FROM kasmweb/kasmos-desktop:1.19.0-rolling-weekly

ARG UPSTREAM_DIGEST=unknown
ARG TARGETARCH=amd64
LABEL org.opencontainers.image.base.digest=$UPSTREAM_DIGEST

USER root

# Install networking utilities, plus gvfs (smb://, sftp:// support in Files)
# and a couple extra apps (Kate, Konsole).
# Also agent/jump-box tooling: sshpass/expect/tmux, jq, fd, L2/SNMP/SMB/LDAP
# clients, serial console, plus the GitHub CLI (apt repo), yq and tea (binaries).
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
    sshpass \
    expect \
    jq \
    ripgrep \
    fd-find \
    tmux \
    fping \
    arp-scan \
    arping \
    ethtool \
    sipcalc \
    smbclient \
    cifs-utils \
    snmp \
    ldap-utils \
    picocom \
    strace \
    htop \
    tree \
    nftables \
    python3-pip \
    && ln -s /usr/bin/fdfind /usr/local/bin/fd \
    && usermod -aG wireshark kasm-user \
    && rm -rf /var/lib/apt/lists/*

# GitHub CLI from the official apt repo (Debian's packaged gh is old).
RUN export DEBIAN_FRONTEND=noninteractive && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

# yq (mikefarah) and tea (Gitea CLI) as static binaries, latest release at build time.
RUN curl -fsSL -o /usr/local/bin/yq \
      "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${TARGETARCH}" && \
    TEA_VERSION="$(curl -fsSL https://gitea.com/api/v1/repos/gitea/tea/releases/latest | jq -er .tag_name | sed 's/^v//')" && \
    curl -fsSL -o /usr/local/bin/tea \
      "https://dl.gitea.com/tea/${TEA_VERSION}/tea-${TEA_VERSION}-linux-${TARGETARCH}" && \
    chmod 0755 /usr/local/bin/yq /usr/local/bin/tea && \
    yq --version && tea --version

USER 1000
