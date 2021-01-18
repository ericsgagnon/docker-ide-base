# docker build --pull -t ericsgagnon/ide-base:dev -f Dockerfile .
# docker build -t ericsgagnon/ide-base:dev -f Dockerfile .
# docker run -dit --name ide ericsgagnon/ide-base:dev
# docker build -t ericsgagnon/ide-base:$(date +%Y%m%d%H%M%S) -f Dockerfile .
# docker build -t ericsgagnon/ide-base:ubuntu20.04-cuda11.1 -f Dockerfile .
# overview:
# - uses nvidia cuda devel as base
# - copies buildpack-deps for first steps
# - adds additional odbc and utility packages (netstat, tcpdump, etc.)
# - adds multiple languages: go, python, Go


# ARG GOLANG_VERSION=1.15
# ARG RUST_VERSION=1.47
# #ARG R_VERSION=4.0.3
# ARG PYTHON_VERSION=3.9
# #ARG OIC_VERSION=19.6
# #ARG CODE_SERVER_VERSION=3.7.1

# FROM golang:${GOLANG_VERSION}       as golang
# FROM rocker/geospatial:${R_VERSION} as rlang
# FROM rust:${RUST_VERSION}           as rustlang
# FROM python:${PYTHON_VERSION}       as python

FROM golang:latest         as golang
FROM rust:latest           as rust
FROM python:latest         as python
FROM openjdk:latest        as java
FROM rocker/ml-verse:4.0.3 as rlang

FROM ericsgagnon/buildpack-deps-cuda:ubuntu20.04-cuda11.0 as base

# ARG GOLANG_VERSION
# ARG RUST_VERSION
# ARG R_VERSION
# ARG PYTHON_VERSION
# ARG OIC_VERSION
# ARG CODE_SERVER_VERSION


# environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV LANG=en_US.UTF-8
#ENV LC_ALL=en_US.UTF-8
ENV PASSWORD password
ENV SHELL=/bin/bash
ENV WORKSPACE=/workspace
ENV FREETDS_VERSION=1.2.18
#ENV PROTOBUF_VERSION=v3.14.0
ENV CUDA_HOME               /usr/local/cuda

# this may not be necessary but may give insight on source files
COPY . ${WORKSPACE}/

RUN chsh -s /bin/bash

##################################################################################################################

# install os libraries, utilities, etc. - some of these are already installed in buildpack-deps
RUN apt-get update \
    && apt-get upgrade -y \
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
ENV LD_PRELOAD=/usr/lib/libnss_wrapper.so:$LD_PRELOAD \
    LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:$LD_LIBRARY_PATH \
    NSS_WRAPPER_PASSWD=/etc/passwd \
    NSS_WRAPPER_GROUP=/etc/group

# user home directories ####################################################

RUN mkdir -p \
    /etc/skel/.local/bin   \
    /etc/skel/.local/share \
    /etc/skel/.config      \
    /etc/skel/.cache       \
    && echo 'export PATH=$HOME/.local/bin:$PATH'           >> /etc/skel/.bashrc
#    && echo 'export LD_LIBRARY_PATH=/usr/lib:/usr/local/lib:$LD_LIBRARY_PATH' >> /etc/skel/.bashrc 
#    && cat $WORKSPACE/bashrc.env.sh | envsubst >> /etc/skel/.bashrc

COPY skel-rsync.sh /etc/profile.d/
# Databases ################################################################

FROM base as databases

# Install os drivers for common db's 
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    unixodbc \
    unixodbc-dev \
    libaio1 \
    tdsodbc \
    odbc-postgresql \
    libsqliteodbc \
    mariadb-client

COPY ./odbcinst.ini /opt/odbcinst.ini

# microsoft ###################################################################################
# ms still demands accepting their license agreement...
ENV ACCEPT_EULA Y
ENV PATH=$PATH:/opt/mssql-tools/bin

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/msprod.list

RUN apt-get update && apt-get install -y mssql-tools

# oracle ######################################################################################
ENV OCI_LIB=/opt/oracle/instantclient

COPY ./oci8.pc /usr/lib/pkgconfig/oci8.pc

RUN mkdir /opt/oracle && cd /opt/oracle \  
    && for file in basic odbc sqlplus tools sdk jdbc ; do \
        wget -O "instantclient-${file}" "https://download.oracle.com/otn_software/linux/instantclient/instantclient-${file}-linuxx64.zip" ; \
        unzip instantclient-${file} ; \
        rm -f instantclient-${file} ; \
        done \
    && mv /opt/oracle/instantclient_* /opt/oracle/instantclient \
    && sh -c "echo /opt/oracle/instantclient > /etc/ld.so.conf.d/oracle-instantclient.conf" \
    && ldconfig

# freetds #####################################################################################
RUN mkdir /opt/freetds && cd /opt/freetds \
    && wget -O freetds.tar.gz ftp://ftp.freetds.org/pub/freetds/stable/freetds-$FREETDS_VERSION.tar.gz \
    && tar xvf freetds.tar.gz \
    && rm freetds.tar.gz \
    && ln -s freetds-$FREETDS_VERSION freetds \
    && cd freetds \
    && ./configure \
    && make \
    && make install \
    && cat /opt/odbcinst.ini >> /etc/odbcinst.ini \
    && rm /opt/odbcinst.ini \
    && ldconfig

# RUN mkdir /opt/freetds && cd /opt/freetds \
#     && wget -O freetds.tar.gz ftp://ftp.freetds.org/pub/freetds/current/freetds-current.tar.gz \
#     && tar xvf freetds.tar.gz \
#     && rm freetds.tar.gz \
#     && ln -s freetds-$FREETDS_VERSION freetds \
#     && cd freetds \
#     && ./configure \
#     && make \
#     && make install \
#     && cat /opt/odbcinst.ini >> /etc/odbcinst.ini \
#     && rm /opt/odbcinst.ini \
#     && ldconfig

# python ##################################################

FROM databases as languages

# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH
ENV PYTHON_VERSION=${PYTHON_VERSION}

COPY --from=python /usr/local/lib/  /usr/local/lib/
COPY --from=python /usr/local/bin/  /usr/local/bin/

RUN ldconfig

# go ######################################################
ARG GOLANG_VERSION=${GOLANG_VERSION}

ENV GOLANG_VERSION=${GOLANG_VERSION}
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

COPY --from=golang  /usr/local/go /usr/local/go
COPY --from=golang  /go           /go

RUN 
# RUN apt-get update && apt-get install -y --no-install-recommends \
# 		g++ \
# 		gcc \
# 		libc6-dev \
# 		make \
# 		pkg-config && \
#     chmod -R 777 "$GOPATH" && \
#     chsh -s /bin/bash
# ENV SHELL=/bin/bash

# rust ####################################################

ARG RUST_VERSION
ENV RUST_VERSION=${RUST_VERSION}

ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH=/usr/local/cargo/bin:$PATH

COPY --from=rust  /usr/local/rustup /usr/local/rustup
COPY --from=rust  /usr/local/cargo /usr/local/cargo

# java ####################################################

ENV PATH=/usr/java/openjdk-15/bin:$PATH
ENV JAVA_HOME=/usr/java/openjdk-15

COPY --from=java      /usr/java  /usr/java

FROM languages as debug
# docker build --pull -t ericsgagnon/ide-base:dev --target debug -f Dockerfile .
# docker run -dit --name idedev ericsgagnon/ide-base:dev

# javascript/node ################################
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    && curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y yarn

# R ###########################################################

FROM debug as final

COPY  --from=rlang /usr/local/lib/R                /usr/local/lib/R
COPY  --from=rlang /usr/local/bin/R                /usr/local/bin/
COPY  --from=rlang /usr/local/bin/install2.r       /usr/local/bin/
COPY  --from=rlang /usr/local/bin/installGithub.r  /usr/local/bin/
COPY  --from=rlang /usr/local/bin/r                /usr/local/bin/
COPY  --from=rlang /usr/local/bin/Rscript          /usr/local/bin/
COPY  --from=rlang /etc/R                          /etc/R
#COPY  --from=rlang /usr/local/bin/ /usr/local/bin/

ENV CRAN="https://packagemanager.rstudio.com/all/__linux__/focal/latest"
ENV R_ENVIRON_USER=~/.config/R/.Renviron
ENV R_PROFILE_USER=~/.config/R/.Rprofile
ENV R_VERSION=4.0

# RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
#     && add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/' \
#     && apt-get update \
#     && R CMD javareconf

RUN apt-get update && apt-get install -y \
    tcl \
    tk \
    tk-dev \
    tk-table \
    jags \
    bwidget \
    mongodb \
    pandoc \
    bowtie2 \
    imagej \
    libpng-dev \
    imagemagick \
    libatk1.0-dev \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libfftw3-dev \
    libglib2.0-dev \
    libglpk-dev \
    libgmp3-dev \
    libgtk2.0-dev \
    libjpeg-dev \
    libleptonica-dev \
    libmagick++-dev \
    libmpfr-dev \
    libopenmpi-dev \
    libpango1.0-dev \
    libpng-dev \
    libpoppler-cpp-dev \
    libsecret-1-dev \
    libsodium-dev \
    libssl-dev \
    libtesseract-dev \
    libudunits2-dev \
    libv8-dev \
    libwebp-dev \
    libxml2-dev \
    pari-gp \
    saga \
    texlive \
    zlib1g-dev



# RUN mkdir -p /etc/skel/.local/share/R/$R_VERSION/lib  \
#     && echo "R_LIBS_USER=${R_LIBS_USER-'~/.local/share/R/"$R_VERSION"/lib'}"        >> /usr/local/lib/R/etc/Renviron \
#     && echo "R_VERSION=$R_VERSION"                                          >> /usr/local/lib/R/etc/Renviron \
#     && echo "R_VERSION=$R_VERSION"                                                  >> /usr/local/lib/R/etc/Renviron \
#     && echo "R_ENVIRON_USER=$R_ENVIRON_USER"                                        >> /usr/local/lib/R/etc/Renviron \
#     && echo "R_PROFILE_USER=$R_PROFILE_USER"                                        >> /usr/local/lib/R/etc/Renviron \
#     && echo "CRAN=$CRAN"                                                            >> /usr/local/lib/R/etc/Renviron 

# commenting during dev to improve build time
# RUN xargs -I {} -a /tmp/packages -0 install2.r -s --deps TRUE -n 8 {} # not this one - behavior changed when moving to ubuntu
#RUN head -n 2 $WORKSPACE/Rpackages | tr '\n' ' ' | install2.r -s --deps TRUE -n 8 
# RUN install2.r -s --deps TRUE -n 8  $(cat $WORKSPACE/Rpackages | tr '\n' ' ')



#env LD_PRELOAD=libnvblas.so 






# protocol buffers ############################################################################
# this is too much of a pain for now - defaulting to os package (above)

# RUN mkdir /usr/local/protocolbuffers \
#     && PB_REL="https://github.com/protocolbuffers/protobuf/releases" ; \
#     curl -L -o /tmp/protoc.zip \
#     $PB_REL/download/v$PROTOBUF_VERSION/protoc-$PROTOBUF_VERSION-linux-x86_64.zip \
#     && unzip /tmp/protoc.zip /usr/local/
# RUN curl -LO $( curl -H "Accept: application/vnd.github.v3+json" \
#     "https://api.github.com/repos/protocolbuffers/protobuf/releases/latest" | \
#     jq ".assets | .[] | .browser_download_url " | grep linux | grep x86 | grep 64 )
#curl -s https://api.github.com/repos/protocolbuffers/protobuf/releases/latest | jq -r ".assets[] | select(.name | contains(\"search param for specific download url\")) | .browser_download_url" | wget -i -    
# ln -s  /usr/local/protocolbuffers/bin/protoc /usr/local/bin/protoc
# https://api.github.com/repos/protocolbuffers/protobuf/zipball/v3.14.0"

# github cli ##################################################################################
# https://github.com/cli/cli/blob/trunk/docs/install_linux.md 

# RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0 \
#     && apt-add-repository https://cli.github.com/packages \
#     && apt update \
#     && apt install -y gh



# create user #################################################################################
# using a 'standard' user for now - may make dynamic in the future

#RUN useradd liverware -u 1138 -s /bin/bash -m \
#    && echo "liveware ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

















