# docker build --pull -t ericsgagnon/ide-base:dev-final -f Dockerfile .
# docker build --build-arg=GIT_TAG=$(git describe --tags) --pull -t ericsgagnon/ide-base:$(git describe --tags)-final -f Dockerfile .
# docker run -i -t --rm --name ide --gpus all ericsgagnon/ide-base:$(git describe --tags)-final /bin/bash
# docker push ericsgagnon/ide-base:$(git describe --tags)-final
# docker run -d -i -t --name ide --gpus all ericsgagnon/ide-base:$(git describe --tags)-final
# docker run --rm --name ide --gpus all ericsgagnon/ide-base:dev-final nvidia-smi

ARG GIT_TAG=dev
ARG STAGE=final
ARG TAG=${GIT_TAG}-${STAGE}

FROM ericsgagnon/ide-base:${GIT_TAG}-languages as base

# this may not be necessary but may give insight on source files
ENV WORKSPACE="/tmp/workspace/final"
COPY . ${WORKSPACE}/

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
    postgresql \
    odbc-postgresql \
    libsqliteodbc \
    mariadb-client

COPY ./odbcinst.ini /opt/odbcinst.ini

# microsoft ###################################################################################
# ms still demands accepting their license agreement...
ENV ACCEPT_EULA=Y
ENV PATH=$PATH:/opt/mssql-tools/bin

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/msprod.list

RUN apt-get update && apt-get install -y mssql-tools

# oracle ######################################################################################
ENV OCI_LIB=/opt/oracle/instantclient
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient:$LD_LIBRARY_PATH
ENV PATH=/opt/oracle/instantclient:$PATH

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

RUN /opt/oracle/instantclient/odbc_update_ini.sh \
    / \
    /opt/oracle/instantclient \
    "Oracle ODBC Driver" \
    "Oracle ODBC Driver" \
    /etc/odbc.ini

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

# python ##################################################

FROM databases as languages

# ensure local python is preferred over distribution python
ENV PATH=/usr/local/bin:$PATH
ENV PYTHON_VERSION=${PYTHON_VERSION}

COPY --from=python /usr/local/lib/  /usr/local/lib/
COPY --from=python /usr/local/bin/  /usr/local/bin/

RUN ldconfig

# go ######################################################
#ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

COPY --from=golang  /usr/local/go /usr/local/go
#COPY --from=golang  /go           /go

RUN mkdir -p /etc/skel/.local/share/go \
    && echo 'export GOPATH=$HOME/.local/share/go' >> /etc/skel/.bashrc

#    /etc/skel/.local/bin/go \
#    && echo 'export GOBIN=$HOME/.local/bin/go'    >> /etc/skel/.bashrc

# rust ####################################################

# rust doesn't like system-wide 
ENV RUSTUP_HOME='~/.local/share/rustup'
ENV CARGO_HOME='~/.local/share/cargo'

RUN    mkdir -p /etc/skel/.local/share/rustup \
    && mkdir -p /etc/skel/.local/share/cargo 

#ENV RUSTUP_HOME=/usr/local/rustup
#ENV CARGO_HOME=/usr/local/cargo

# COPY --from=rust  /usr/local/rustup /usr/local/rustup
# COPY --from=rust  /usr/local/cargo /usr/local/cargo


# ENV PATH=/usr/local/cargo/bin:$PATH
# ENV PATH=\$HOME/.local/share/cargo/bin:$PATH

    # && chmod +x /usr/local/cargo/env \
    #&& echo "rustup self update"
    #&& echo "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y &> /dev/null " >> /etc/skel/.bashrc

#     && echo "source <(rustup completions bash)" >> /etc/profile.d/base-env.sh \
#     && echo "source <(rustup completions bash)" >> /etc/skel/.bashrc \
#     && echo 'source "/usr/local/cargo/env"'     >> /etc/profile.d/base-env.sh \
#     && echo 'source "/usr/local/cargo/env"'     >> /etc/skel/.bashrc \
#     && echo 'rustup install stable' \
#     #&& rustup default stable

# java ####################################################

ENV PATH=/usr/java/openjdk-15/bin:$PATH
ENV JAVA_HOME=/usr/java/openjdk-15

COPY --from=java      /usr/java  /usr/java

# javascript/node ################################
# RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
#     && apt-get update \
#     && apt-get install -y nodejs \
#     && curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
#     && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
#     && apt-get update \
#     && apt-get install -y yarn

# javascript/node ################################
# can't use apt to install node without losing libnode-dev and libnode64, 
# so copying from node docker image
COPY  --from=node /usr/local  /tmp/node/local
COPY  --from=node /opt        /tmp/node/opt

RUN rsync -a --ignore-existing /tmp/node/local/ /usr/local/ \
    && rsync -a --ignore-existing /tmp/node/opt/ /opt/ \
    && rm -rf /tmp/node

# R ###########################################################

COPY  --from=rlang /usr/local/lib/R                /usr/local/lib/R
COPY  --from=rlang /usr/local/bin/R                /usr/local/bin/
COPY  --from=rlang /usr/local/bin/install2.r       /usr/local/bin/
COPY  --from=rlang /usr/local/bin/installGithub.r  /usr/local/bin/
COPY  --from=rlang /usr/local/bin/r                /usr/local/bin/
COPY  --from=rlang /usr/local/bin/Rscript          /usr/local/bin/
COPY  --from=rlang /etc/R                          /etc/R
#COPY  --from=rlang /usr/local/bin/ /usr/local/bin/

ENV CRAN="https://packagemanager.rstudio.com/all/__linux__/focal/latest"
ENV R_ENVIRON_USER="~/.config/R/.Renviron"
ENV R_PROFILE_USER="~/.config/R/.Rprofile"
ENV R_VERSION=4.0
ENV R_LIBS_USER="~/.local/share/R/$R_VERSION/lib"
ENV R_LIBS="~/.local/share/R/$R_VERSION/lib"
ENV WORKON_HOME="~/.virtualenvs"

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
    poppler-utils \
    saga \
    texlive \
    vim.tiny \
    zlib1g-dev

# commenting during dev to improve build time
RUN install2.r -s --deps TRUE -n 8  $(cat $WORKSPACE/Rpackages | tr '\n' ' ')

RUN mkdir -p /etc/skel/.local/share/R/$R_VERSION/lib  \
    && echo "R_LIBS_USER=${R_LIBS_USER-'~/.local/share/R/"$R_VERSION"/lib'}"        >> /usr/local/lib/R/etc/Renviron \
    && echo "R_VERSION=$R_VERSION"                                                  >> /usr/local/lib/R/etc/Renviron \
    && echo "R_ENVIRON_USER=$R_ENVIRON_USER"                                        >> /usr/local/lib/R/etc/Renviron \
    && echo "R_PROFILE_USER=$R_PROFILE_USER"                                        >> /usr/local/lib/R/etc/Renviron \
    && echo "CRAN=$CRAN"                                                            >> /usr/local/lib/R/etc/Renviron 
    #&& echo "R_LIBS=${R_LIBS_USER-'~/.local/share/R/"$R_VERSION"/lib'}"             >> /usr/local/lib/R/etc/Renviron \

RUN mkdir -p /etc/skel/.config/R \
    && cat $WORKSPACE/.Renviron | envsubst > /etc/skel/.config/R/.Renviron

# user-utilities ##############################################################################

FROM languages as user-utilities

# helm ####################################################
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -

# docker cli ##############################################
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" \
    && apt-get update && apt-get install -y \
    docker-ce-cli

# github cli ##################################################################################
# https://github.com/cli/cli/blob/trunk/docs/install_linux.md #################################
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0 \
    && apt-add-repository https://cli.github.com/packages \
    && apt-get update \
    && apt-get install -y gh

FROM user-utilities as final

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

COPY s6-container-env-vars.sh /etc/cont-init.d/
COPY s6-userconf.sh /etc/cont-init.d/

# setup entrypoint ############################################################################
#RUN mkdir -p /entrypoint/entrypoint.d
#COPY entrypoint.sh /entrypoint/entrypoint.sh

# create user #################################################################################
# using a 'standard' user for now - may make dynamic in the future
ENV USER=liveware
ENV USERID=1138
ENV GROUP=liveware
ENV GROUPID=1138
ENV GROUPS=''
ENV UPDATE_PASSWORD=false
ENV PASSWORD_FILE=''
ENV PASSWORD=password
ENV ROOT=true
#ENTRYPOINT "/bin/bash"

ENTRYPOINT [ "/init" ]

# use bash as default cmd
CMD [ "/bin/bash" ]
