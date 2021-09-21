
ARG VERSION=dev

FROM ericsgagnon/ide-base:${VERSION}-base as base

# this may not be necessary but may give insight on source files
ENV WORKSPACE=/tmp/workspace/ide-base/databases
COPY . ${WORKSPACE}/

# Install os drivers for common db's 
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    gperf \
    unixodbc \
    unixodbc-dev \
    libaio1 \
    postgresql \
    odbc-postgresql \
    libsqliteodbc \
    mariadb-client

COPY ./odbcinst.ini /opt/odbcinst.ini
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/odbc:${LD_LIBRARY_PATH}
# prevent upgrades to unixodbc that remove some of the lib's in /usr/lib/x86_64-linux-gnu/odbc
RUN apt-mark hold unixodbc

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt-get update \
    && apt-get -y install \
    postgresql  \
    ora2pg \
    pgloader \
    cl-pgloader

# microsoft ###################################################################################
# ms still demands accepting their license agreement...
ENV ACCEPT_EULA=Y
ENV PATH=${PATH}:/opt/mssql-tools/bin

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/msprod.list

RUN apt-get update && apt-get install -y mssql-tools

# oracle ######################################################################################
ENV OCI_LIB=/opt/oracle/instantclient
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient:${LD_LIBRARY_PATH}
ENV PATH=/opt/oracle/instantclient:${PATH}

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

# openssl 1.0.2 ###############################################################################
# some older db instances uses encryption that's no longer supported openssl 1.1.1+
# install in /usr/local/ssl to avoid conflict with distro install in /usr
RUN mkdir /tmp/openssl && cd /tmp/openssl \
    && wget -O openssl.tar.gz https://www.openssl.org/source/old/1.0.2/openssl-1.0.2u.tar.gz \
    && tar xvf openssl.tar.gz \
    && cd openssl-1.0.2u \
    && ./config \
    enable-weak-ssl-ciphers \
    enable-md2 \
    enable-rc5 \
    && make depend \
    && make \
    && make install \
    && cd / && rm -rf /tmp/openssl

# freetds #####################################################################################
RUN cd /tmp \
    && git clone https://github.com/freetds/freetds \
    && cd freetds \
    && sh ./autogen.sh \
    && make \
    && make install \
    && sh ./autogen.sh \
    --with-openssl=/usr/local/ssl/lib \
    --prefix=/usr/local/freetds-openssl-102 \
    && make \
    && make install \
    && cat ${WORKSPACE}/odbcinst.ini >> /etc/odbcinst.ini \
    && cd /tmp \
    && rm -rf freetds \
    && ldconfig



