
ARG VERSION=dev

FROM golang:latest         as golang
FROM tinygo/tinygo:latest  as tinygo
FROM openjdk:latest        as java
# FROM python:3.9            as python-3-9
# FROM python:latest as python 
# RUN echo ${PYTHON_VERSION} > /tmp/PYTHON_VERSION

FROM ericsgagnon/ide-base:${VERSION}-databases as base

# this may not be necessary but may give insight on source files
ENV WORKSPACE=/tmp/workspace/ide-base/languages
COPY . ${WORKSPACE}/
# COPY --from=python /tmp/PYTHON_VERSION ${WORKSPACE}/PYTHON_VERSION
# python #########################################################

# prep
RUN apt-get update && apt-get -y install \
    binfmtc \
    binfmt-support \
    build-essential \
    ca-certificates \
    zlib1g-dev \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \
    libssl-dev \
    libreadline-dev \
    libffi-dev \
    libsqlite3-dev \
    libbz2-dev \
    software-properties-common

# python ####################

RUN add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y \
    $(for v in 3.9 3.10 3.11; do echo \
    python$v \
    python$v-dev \
    python$v-venv \
    python$v-distutils \
    python$v-lib2to3 \
    idle-python$v \
    ; done)

# # make some useful symlinks that are expected to exist

RUN for v in 3.11; do \
    cd /usr/local/bin \
    && ln -f -s $(which idle-python$v) idle \
    && ln -f -s $(which pydoc$v) pydoc      \
    && ln -f -s $(which python$v) python    \
    && ln -f -s $(which python$v-config) python-config \
    ; done


# RUN cd /usr/local/bin \
#     && ln -f -s $(which idle-python3.9) idle     \
#     && ln -f -s $(which pydoc3.9) pydoc    \
#     && ln -f -s $(which python3.9) python \
#     && ln -f -s $(which python3.9-config) python-config
# python - latest ###############
# build latest python from source
# RUN export PYTHON_VERSION=$(cat ${WORKSPACE}/PYTHON_VERSION) \
#     && apt-get update && apt-get -y install \
#     binfmtc \
#     binfmt-support \
#     build-essential \
#     ca-certificates \
#     zlib1g-dev \
#     libncurses5-dev \
#     libgdbm-dev \
#     libnss3-dev \
#     libssl-dev \
#     libreadline-dev \
#     libffi-dev \
#     libsqlite3-dev \
#     libbz2-dev \
#     && cd /tmp \
#     && wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-${PYTHON_VERSION}.tar.xz" \
#     && mkdir -p /usr/src/python \
#     && tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
#     && rm python.tar.xz \
#     && cd /usr/src/python \
#     && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
#     && ./configure \
#         --build="$gnuArch" \
#         --enable-loadable-sqlite-extensions \
#         --enable-optimizations \
#         --enable-option-checking=fatal \
#         --enable-shared \
#         --with-system-expat \
#         --with-system-ffi \
#         --without-ensurepip \
#     && make -j "$(nproc)" \
#     && make install \
#     && rm -rf /usr/src/python \
#     && ldconfig

# ENV PATH=/usr/local/bin:${PATH}

# # make some useful symlinks that are expected to exist
# RUN cd /usr/local/bin \
#     && ln -f -s $(which idle3) idle     \
#     && ln -f -s $(which pydoc3) pydoc   \
#     && ln -f -s $(which python3) python \
#     && ln -f -s $(which python3-config) python-config

# RUN python -m ensurepip \
#     && python -m ensurepip --upgrade \
#     && python -m pip install -U pip \
#     && ln -f -s $(which pip3) /usr/local/bin/pip

# go ######################################################
COPY --from=golang  /usr/local/go /usr/local/go
RUN mkdir -p \
    /etc/skel/.local/share/go \
    /etc/skel/.local/bin/go   
ENV PATH=/usr/local/go/bin:${PATH}

# tinygo ##################################################
COPY --from=tinygo  /usr/local/tinygo  /usr/local/tinygo
ENV PATH=/usr/local/tinygo/bin:${PATH}
# RUN export TINYGO_VERSION=${TINYGO_VERSION:-0.25.0} \
#     && cd /tmp \
#     && wget -O tinygo.deb https://github.com/tinygo-org/tinygo/releases/download/v${TINYGO_VERSION}/tinygo_${TINYGO_VERSION}_amd64.deb \
#     && dpkg -i tinygo.deb \
#     && rm tinygo.deb

# rust ####################################################

RUN mkdir -p /etc/skel/.local/share/rustup \
    && mkdir -p /etc/skel/.local/share/cargo 

# java ####################################################

ENV JAVA_HOME=/usr/java/latest
ENV PATH=${JAVA_HOME}/bin:${PATH}

COPY --from=java      /usr/java  /usr/java

# javascript/node ################################
# can't use apt to install node without losing libnode-dev and libnode64, 
# so copying from node docker image

RUN mkdir -p \
    /etc/skel/.local/share/nvm \
    /etc/skel/.config/npm \
    /etc/skel/.cache/npm \
    /etc/skel/.config/yarn \
    /etc/skel/.cache/yarn \
    /etc/skel/.local/share/yarn

# R ###########################################################
ENV CRAN="https://packagemanager.rstudio.com/all/__linux__/jammy/latest"

RUN apt-get update && apt-get install -y \
    tcl \
    tk \
    tk-dev \
    tk-table \
    jags \
    bwidget \
    pandoc \
    bowtie2 \
    imagej \
    graphviz \
    gsfonts \
    graphviz-doc \
    fonts-liberation \
    graphviz \
    libann0 \
    libcdt5 \
    libcgraph6 \
    libgts-0.7-5 \
    libgts-bin \
    libgvc6 \
    libgvpr2 \
    liblab-gamut1 \
    libpathplan4 \
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


    # && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
    # && add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" \
    # r-cran-mleap \
RUN    apt update -y -qq \
    && wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | gpg --dearmor -o /usr/share/keyrings/r-project.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/r-project.gpg] https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/" | tee -a /etc/apt/sources.list.d/r-project.list \
    && apt-get update \
    && apt-get install -y \
    r-base \
    r-base-dev \
    && add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable \
    && apt-get update \
    && add-apt-repository -y ppa:c2d4u.team/c2d4u4.0+ \
    && apt-get update \
    && apt-get install -y \
    jags \
    python3-rpy2 \
    littler \
    libgdal-grass \
    libgdal-dev \
    gdal-bin \
    gdal-data \
    python3-gdal \
    r-cran-bayesmix \
    r-cran-bigrquery \
    r-cran-biocmanager \
    r-cran-boot \
    r-cran-class \
    r-cran-cluster \
    r-cran-codetools \
    r-cran-dbi \
    r-cran-dbplyr \
    r-cran-desctools \
    r-cran-diagrammer \
    r-cran-docopt \
    r-cran-dygraphs \
    r-cran-feather \
    r-cran-foreign \
    r-cran-ggally \
    r-cran-googleauthr \
    r-cran-googledrive \
    r-cran-googlevis \
    r-cran-hms \
    r-cran-jagsui \
    r-cran-rjdbc \
    r-cran-jsonlite \
    r-cran-kernsmooth \
    r-cran-laplacesdemon \
    r-cran-lattice \
    r-cran-leaflet \
    r-cran-littler \
    r-cran-lme4 \
    r-cran-lmertest \
    r-cran-mass \
    r-cran-matrix \
    r-cran-mcmc \
    r-cran-mgcv \
    r-cran-mongolite \
    r-cran-neuralnet \
    r-cran-nimble \
    r-cran-nlme \
    r-cran-nnet \
    r-cran-odbc \
    r-cran-onnx \
    r-cran-plotly \
    r-cran-pmml \
    r-cran-pool \
    r-cran-qgraph \
    r-cran-r2jags \
    r-cran-rcmdrplugin.rmtcjags \
    r-cran-recipes \
    r-cran-redcapapi \
    r-cran-refmanager \
    r-cran-repr \
    r-cran-reprex \
    r-cran-reticulate \
    r-cran-rgdal \
    r-cran-rjags \
    r-cran-rlang \
    r-cran-rmariadb \
    r-cran-rodbc \
    r-cran-rorcid \
    r-cran-rpart \
    r-cran-rpostgis \
    r-cran-rpostgres \
    r-cran-rprotobuf \
    r-cran-rstan \
    r-cran-rstanarm \
    r-cran-runjags \
    r-cran-shinydashboard \
    r-cran-shinyjs \
    r-cran-shinystan \
    r-cran-shinythemes \
    r-cran-shinywidgets \
    r-cran-sparklyr \
    r-cran-spatial \
    r-cran-survival \
    r-cran-tensorflow \
    r-cran-tfdeploy \
    r-cran-tfestimators \
    r-cran-tibbletime \
    r-cran-tidypredict \
    r-cran-tidyquant \
    r-cran-tidytext \
    r-cran-tidyverse \
    r-cran-tm \
    r-cran-xgboost

RUN export R_VERSION=$(R --version | grep -E "^R version " | sed -r "s/^R version ([[:digit:]]+\\.[[:digit:]]).*/\\1/g" ) \
 && echo "#env's inserted during image build" >> /etc/R/Renviron.site \
 && echo "R_VERSION=${R_VERSION}"             >> /etc/R/Renviron.site \
 && cat ${WORKSPACE}/Renviron.site            >> /etc/R/Renviron.site \
 && cat ${WORKSPACE}/Rprofile.site            >> /etc/R/Rprofile.site \
 && mkdir -p /etc/skel/.local/share/R/${R_VERSION}/lib                \
 && mkdir -p /etc/skel/.config/R                                      \
 && cp  ${WORKSPACE}/Renviron.user                          /etc/skel/.config/R/Renviron      \
 && cp  ${WORKSPACE}/Rprofile.user                          /etc/skel/.config/R/Rprofile      \
 && cat ${WORKSPACE}/001-userconf.sh                     >> /etc/cont-init.d/001-userconf.sh  

RUN for f in $(ls  /usr/lib/R/site-library/littler/examples/) ; \
        do ln -s /usr/lib/R/site-library/littler/examples/$f /usr/local/bin/$f  ; done

RUN install2.r -s --deps TRUE -n 8  $(cat ${WORKSPACE}/Rpackages | tr '\n' ' ')

RUN mkdir -p /etc/skel/.local/share/R/${R_VERSION}/lib \
 && mkdir -p /etc/skel/.config/R \
 && cp  ${WORKSPACE}/Renviron.user                /etc/skel/.config/R/Renviron      \
 && cp  ${WORKSPACE}/Rprofile.user                /etc/skel/.config/R/Rprofile      \
 && cat ${WORKSPACE}/001-userconf.sh           >> /etc/cont-init.d/001-userconf.sh  \
 && cat ${WORKSPACE}/000-env.sh                >> /etc/cont-init.d/000-env.sh

RUN apt-get update \
    && apt-get install -y apt-transport-https \
    && apt-get update \
    && apt-get install -y \
    dotnet-sdk-6.0 \
    aspnetcore-runtime-6.0

# let's make sure no nvidia drivers made it through:
# RUN apt-get remove -y libxnvctrl0 cuda-compat-11-3
# RUN apt autoremove
