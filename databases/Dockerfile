# docker build --pull -t ericsgagnon/ide-base:dev-databases -f Dockerfile .
# docker build --build-arg=GIT_TAG=$(git describe --tags) --pull -t ericsgagnon/ide-base:$(git describe --tags)-databases -f Dockerfile .
# docker run -i -t --rm --name ide --gpus all ericsgagnon/ide-base:$(git describe --tags)-databases /bin/bash
# docker push ericsgagnon/ide-base:$(git describe --tags)-databases
# docker run -d -i -t --name ide --gpus all ericsgagnon/ide-base:$(git describe --tags)-databases
# docker run --rm --name ide --gpus all ericsgagnon/ide-base:dev-databases nvidia-smi

ARG GIT_TAG=dev
ARG STAGE=databases
ARG TAG=${GIT_TAG}-${STAGE}

FROM ericsgagnon/ide-base:${GIT_TAG}-base as base

# environment variables
ENV FREETDS_VERSION=1.2.18

# this may not be necessary but may give insight on source files
ENV WORKSPACE=/tmp/workspace/ide-base/databases
COPY . ${WORKSPACE}/

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

