
ARG VERSION=dev

FROM golang:latest         as golang
# using python 3.8 until tensorflow supports 3.9
#FROM python:3.8            as python
FROM openjdk:latest        as java
FROM node:latest           as node
FROM rocker/ml-verse:4.0.4 as rlang
FROM ericsgagnon/ide-base:${VERSION}-databases as base

# this may not be necessary but may give insight on source files
ENV WORKSPACE=/tmp/workspace/ide-base/languages
COPY . ${WORKSPACE}/

# ensure local python is preferred over distribution python
ENV PYTHON_VERSION 3.8.8
ENV WORKON_HOME='${HOME}/.virtualenvs'

RUN apt-get update && apt-get -y install \
    build-essential \
    zlib1g-dev \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \
    libssl-dev \
    libreadline-dev \
    libffi-dev \
    libsqlite3-dev \
    libbz2-dev \
    && cd /tmp \
    && wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-${PYTHON_VERSION}.tar.xz" \
    && mkdir -p /usr/src/python \
    && tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
    && rm python.tar.xz \
    && cd /usr/src/python \
    && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
    && ./configure \
        --build="$gnuArch" \
        --enable-loadable-sqlite-extensions \
        --enable-optimizations \
        --enable-option-checking=fatal \
        --enable-shared \
        --with-system-expat \
        --with-system-ffi \
        --without-ensurepip \
    && make -j "$(nproc)" \
    && make install \
    && rm -rf /usr/src/python \
    && ldconfig \
    && python3 --version

# make some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
    && ln -s idle3 idle \
    && ln -s pydoc3 pydoc \
    && ln -s python3 python \
    && ln -s python3-config python-config

RUN python -m ensurepip \
    && python -m ensurepip --upgrade \
    && python -m pip install -U pip

# go ######################################################
ENV GOPATH='${HOME}/.local/share/go'
ENV GOBIN='${HOME}/.local/bin/go'
ENV PATH=/usr/local/go/bin:${PATH}

COPY --from=golang  /usr/local/go /usr/local/go

RUN mkdir -p \
    /etc/skel/.local/share/go \
    /etc/skel/.local/bin/go   
#    && echo "export GOPATH=${GOPATH}"  >> /etc/skel/.bashrc \

# rust ####################################################

# rust doesn't like system-wide, just configuring env vars 
ENV RUSTUP_HOME='${HOME}/.local/share/rustup'
ENV CARGO_HOME='${HOME}/.local/share/cargo'

RUN    mkdir -p /etc/skel/.local/share/rustup \
    && mkdir -p /etc/skel/.local/share/cargo 

# java ####################################################

ENV JAVA_HOME=/usr/java/latest
ENV PATH=${JAVA_HOME}/bin:${PATH}

COPY --from=java      /usr/java  /usr/java

# javascript/node ################################
# can't use apt to install node without losing libnode-dev and libnode64, 
# so copying from node docker image
ENV NVM_DIR='${HOME}/.local/share/nvm'
ENV npm_config_userconfig='${HOME}/.config/npm/.npmrc'
ENV npm_config_cache='${HOME}/.cache/npm'
ENV npm_config_init_module='${HOME}/.config/npm/npm-init.js'
ENV YARN_RC_FILENAME='${HOME}/.config/yarn/yarnrc'
ENV YARN_CACHE_FOLDER='${HOME}/.cache/yarn'

RUN mkdir -p \
    /etc/skel/.local/share/nvm \
    /etc/skel/.config/npm \
    /etc/skel/.cache/npm \
    /etc/skel/.config/yarn \
    /etc/skel/.cache/yarn \
    /etc/skel/.local/share/yarn

# COPY  --from=node /usr/local  /tmp/node/local
# COPY  --from=node /opt        /tmp/node/opt

# RUN    rsync -a --ignore-existing /tmp/node/local/  /usr/local/ \
#     && rsync -a --ignore-existing /tmp/node/opt/    /opt/       \
#     && rm -rf /tmp/node

# R ###########################################################
COPY  --from=rlang /usr/local/lib/R                /usr/local/lib/R
COPY  --from=rlang /usr/local/bin/R                /usr/local/bin/
COPY  --from=rlang /usr/local/bin/install2.r       /usr/local/bin/
COPY  --from=rlang /usr/local/bin/installGithub.r  /usr/local/bin/
COPY  --from=rlang /usr/local/bin/r                /usr/local/bin/
COPY  --from=rlang /usr/local/bin/Rscript          /usr/local/bin/
COPY  --from=rlang /etc/R                          /etc/R
#COPY  --from=rlang /usr/local/bin/ /usr/local/bin/

ENV R_VERSION=4.0
ENV CRAN="https://packagemanager.rstudio.com/all/__linux__/focal/latest"
ENV R_ENVIRON_USER='${HOME}/.config/R/.Renviron'
ENV R_PROFILE_USER='${HOME}/.config/R/.Rprofile'
ENV R_LIBS_USER='${HOME}/.local/share/R/${R_VERSION}/lib'
ENV R_LIBS='${HOME}/.local/share/R/${R_VERSION}/lib'

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
    graphviz \
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
    libpoppler-glib-dev \
    libpoppler-dev \
    libpoppler-cpp0v5 \
    libpoppler-cpp-dev \
    saga \
    texlive \
    vim.tiny \
    zlib1g-dev

# commenting during dev to improve build time
RUN install2.r -s --deps TRUE -n 8  $(cat ${WORKSPACE}/Rpackages | tr '\n' ' ')

RUN mkdir -p /etc/skel/.local/share/R/${R_VERSION}/lib

RUN mkdir -p /etc/skel/.config/R \
    && cp  ${WORKSPACE}/.Renviron                   /etc/skel/.config/R/.Renviron           \
    && cp  ${WORKSPACE}/.Rprofile                   /etc/skel/.config/R/.Rprofile           \
    && cat ${WORKSPACE}/s6-userconf.sh           >> /etc/cont-init.d/s6-userconf.sh         \
    && cat ${WORKSPACE}/s6-container-env-vars.sh >> /etc/cont-init.d/s6-container-env-vars.sh 

