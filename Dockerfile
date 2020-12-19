
# docker build -t ericsgagnon/ide-base:dev -f Dockerfile .
# docker build -t ericsgagnon/ide-base:$(date +%Y%m%d%H%M%S) -f Dockerfile .
# docker build -t ericsgagnon/ide-base:ubuntu20.04-cuda11.1 -f Dockerfile .
# overview:
# - uses nvidia cuda devel as base
# - copies buildpack-deps for first steps
# - adds additional odbc and utility packages (netstat, tcpdump, etc.)
# - adds multiple languages: go, python, Go

FROM ericsgagnon/buildpack-deps-cuda:ubuntu20.04-cuda11.1

# environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV LANG=en_US.UTF-8
ENV PASSWORD password
ENV SHELL=/bin/bash
ENV WORKSPACE=/workspace

# this may not be necessary but may give insight on source files
COPY . ${WORKSPACE}/

RUN chsh -s /bin/bash

##################################################################################################################

# install os libraries, utilities, etc.
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
    && rm -rf /var/lib/apt/lists/*

# nss wrapper lets us mount passwd and group files if necessary
ENV LD_PRELOAD=libnss_wrapper.so \
    LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:$LD_LIBRARY_PATH \
    NSS_WRAPPER_PASSWD=/etc/passwd \
    NSS_WRAPPER_GROUP=/etc/group

# user home directories ####################################################

RUN mkdir -p \
    /etc/skel/.local/bin   \
    /etc/skel/.local/share \
    /etc/skel/.config      \
    /etc/skel/.cache       \
    && echo 'export PATH=$PATH'           >> /etc/skel/.bashrc \
    && cat $WORKSPACE/bashrc.env.sh | envsubst >> /etc/skel/.bashrc

COPY skel-rsync.sh /etc/profile.d/
# Databases ################################################################

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
    && wget -O freetds.tar.gz ftp://ftp.freetds.org/pub/freetds/stable/freetds-1.2.12.tar.gz \  
    && tar xvf freetds.tar.gz \
    && rm freetds.tar.gz \
    && ln -s freetds-1.2.12 freetds \
    && cd freetds \
    && ./configure \
    && make \
    && make install \
    && cat /opt/odbcinst.ini >> /etc/odbcinst.ini \
    && rm /opt/odbcinst.ini



