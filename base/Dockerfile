
# FROM ericsgagnon/buildpack-deps-cuda:cuda11-ubuntu20.04 as base
# FROM ericsgagnon/buildpack-deps-cuda:ubuntu22.04-cuda11.7 as base
# FROM ericsgagnon/buildpack-deps-cuda:cuda11.7-ubuntu22.04 as base
FROM ericsgagnon/buildpack-deps-cuda:cuda12.1-ubuntu22.04 as base

# environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV LANG=en_US.UTF-8
#ENV LC_ALL=en_US.UTF-8
ENV SHELL=/bin/bash
ENV WORKSPACE=/tmp/workspace/ide-base/base
ENV CUDA_HOME=/usr/local/cuda

# this may not be necessary but may give insight on source files
COPY . ${WORKSPACE}/

RUN chsh -s /bin/bash

##################################################################################################################

# install os libraries, utilities, etc. - some of these are already installed in buildpack-deps
RUN apt-get update \
    && apt-get upgrade -y \
    && bash -c 'yes | unminimize' \
    && apt-get install -y \
    autofs \
    hdparm \
    fio \
    bash-completion \
    ca-certificates \
    libnss-wrapper \
    libuid-wrapper \
    libpam-wrapper \
    gettext \
    libbluetooth-dev \
    git-lfs \
    tk-dev \
    uuid-dev \
    lsb-release \
    g++ \
    gcc \
    libc6-dev \
    make \
    pkg-config \
    gnupg \
    gnupg2 \
    apt-transport-https \
    curl \
    net-tools \
    nano \
    apt-utils \
    aptitude \
    man \
    software-properties-common \
    dumb-init \
    htop \
    locales \
    procps \
    ssh \
    sudo \
    less \
    vim \
    libpam-mount \
    cifs-utils \
    nfs-common \
    sshfs \
    encfs \
    ecryptfs-utils \
    python3-keyring \
    libsecret-tools \
    lastpass-cli \
    xclip \
    fuse3 \
    libfuse3-dev \
    libopenblas-base \
    libopenblas-dev \
    libopenblas-openmp-dev \
    libopenblas-serial-dev \
    libopenblas0 \
    libopenblas64-0 \
    libopenblas64-dev \
    libopenblas64-openmp-dev \
    libopenblas64-pthread-dev \
    libopenblas64-serial-dev \
    gprename \
    pax \
    rsync \
    iputils-ping \
    netcat \
    dnsutils \
    nmap \
    traceroute \
    vnstat \
    iptraf \
    iftop \
    slurm \
    tcpdump \
    moreutils \
    dmidecode \
    strace \
    nfstrace \
    dnstracer \
    jq \
    protobuf-compiler \
    speedtest-cli \
    iozone3 \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen ${LANG} && dpkg-reconfigure locales

RUN apt update -y && apt upgrade -y && \
    apt install -y --no-install-recommends \
    aptitude \
    man 

RUN ldconfig

ENV PAGER=less

# nss wrapper lets us mount passwd and group files if necessary
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libnss_wrapper.so${LD_PRELOAD:+:${LD_PRELOAD}}
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/usr/local/lib:/usr/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
# /usr/lib/x86_64-linux-gnu/
ENV NSS_WRAPPER_PASSWD=/etc/passwd
ENV NSS_WRAPPER_GROUP=/etc/group

# user home directories ####################################################
ENV ENV_FILE=/etc/profile.d/0000-env.sh
RUN mkdir -p \
    /etc/skel/.local/bin   \
    /etc/skel/.local/share \
    /etc/skel/.config      \
    /etc/skel/.cache       \
    && echo "source ${ENV_FILE}"    >> /etc/skel/.bashrc

# profile ##################################################################
COPY skel-rsync.sh  /etc/profile.d/

# s6 process manager ######################################################
# ADD https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.3/s6-overlay-amd64-installer /tmp/
# https://github.com/just-containers/s6-overlay/releases/v3.1.2.1/
# ADD https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.3/s6-overlay-amd64-installer /tmp/
# RUN chmod +x /tmp/s6-overlay-amd64-installer && /tmp/s6-overlay-amd64-installer /

ADD https://github.com/just-containers/s6-overlay/releases/download/v3.1.2.1/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v3.1.2.1/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

COPY 000-env.sh               /etc/cont-init.d/
COPY 001-userconf.sh          /etc/cont-init.d/
COPY s6-nvidia-check.sh       /etc/cont-init.d/
RUN chmod +x /etc/cont-init.d/*

ENTRYPOINT [ "/init" ]

# disable core dumps 
RUN echo    "*    hard    core    0"           >> /etc/security/limits.d/disable-core-dumps.conf \
    && echo "fs.suid_dumpable=0"               >> /etc/sysctl.d/disable-core-dumps.conf \
    && echo "vm.oom_dump_tasks=0"              >> /etc/sysctl.d/disable-core-dumps.conf \
    && echo 'kernel.core_pattern=|/bin/false'  >> /etc/sysctl.d/disable-core-dumps.conf \
    && echo "ulimit -c 0"                      >> /etc/profile.d/disable-core-dumps.sh

# use bash as default cmd
CMD [ "/bin/bash" ]

