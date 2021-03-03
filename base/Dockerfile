# docker build --pull -t ericsgagnon/ide-base:dev-base -f Dockerfile .
# docker build --build-arg=GIT_TAG=$(git describe --tags) --pull -t ericsgagnon/ide-base:$(git describe --tags)-base -f Dockerfile .
# docker run -i -t --rm --name ide --gpus all ericsgagnon/ide-base:$(git describe --tags)-base /bin/bash
# docker push ericsgagnon/ide-base:$(git describe --tags)-base
# docker run -d -i -t --name ide --gpus all ericsgagnon/ide-base:$(git describe --tags)-base 
# docker run --rm --name ide --gpus all ericsgagnon/ide-base:dev nvidia-smi

ARG GIT_TAG=dev
ARG STAGE=base
ARG TAG=${GIT_TAG}-${STAGE}

FROM ericsgagnon/buildpack-deps-cuda:cuda11.2-ubuntu20.04 as base

# environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV LANG=en_US.UTF-8
#ENV LC_ALL=en_US.UTF-8
ENV PASSWORD=password
ENV SHELL=/bin/bash
ENV WORKSPACE=/workspace
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
    ca-certificates \
    libnss-wrapper \
    libuid-wrapper \
    libpam-wrapper \
    gettext \
    libbluetooth-dev \
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
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen $LANG && dpkg-reconfigure locales

RUN apt update -y && apt upgrade -y && \
    apt install -y --no-install-recommends \
    aptitude \
    man 

RUN ldconfig

# nss wrapper lets us mount passwd and group files if necessary
ENV LD_PRELOAD=/usr/lib/libnss_wrapper.so:$LD_PRELOAD
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:$LD_LIBRARY_PATH
ENV NSS_WRAPPER_PASSWD=/etc/passwd
ENV NSS_WRAPPER_GROUP=/etc/group

# user home directories ####################################################
RUN mkdir -p \
    /etc/skel/.local/bin   \
    /etc/skel/.local/share \
    /etc/skel/.config      \
    /etc/skel/.cache       \
    && echo 'export PATH=$HOME/.local/bin:$PATH'           >> /etc/skel/.bashrc     

COPY skel-rsync.sh /etc/profile.d/

# setup fixuid to deal with potential permission/ownership issues
RUN curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.5/fixuid-0.5-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml

# setup s6 ####################################################################################
# s6 process manager ######################################################
ADD https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.3/s6-overlay-amd64-installer /tmp/
RUN chmod +x /tmp/s6-overlay-amd64-installer && /tmp/s6-overlay-amd64-installer /

COPY s6-container-env-vars.sh   /etc/cont-init.d/
COPY s6-nvidia-check.sh         /etc/cont-init.d/
COPY s6-userconf.sh             /etc/cont-init.d/

ENV USER=liveware
ENV USERID=1138
ENV GROUP=liveware
ENV GROUPID=1138
ENV GROUPS=''
ENV UPDATE_PASSWORD=false
ENV PASSWORD_FILE=''
ENV PASSWORD=password
ENV ROOT=true

ENTRYPOINT [ "/init" ]

# use bash as default cmd
CMD [ "/bin/bash" ]
