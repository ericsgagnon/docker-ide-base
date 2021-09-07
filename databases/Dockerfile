
ARG VERSION=dev

FROM ericsgagnon/ide-base:${VERSION}-base as base

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

# freetds #####################################################################################
RUN mkdir /opt/freetds && cd /opt/freetds \
    && wget -O freetds.tar.gz ftp://ftp.freetds.org/pub/freetds/stable/freetds-${FREETDS_VERSION}.tar.gz \
    && tar xvf freetds.tar.gz \
    && rm freetds.tar.gz \
    && ln -s freetds-${FREETDS_VERSION} freetds \
    && cd freetds \
    && ./configure \
    && make \
    && make install \
    && cat /opt/odbcinst.ini >> /etc/odbcinst.ini \
    && rm /opt/odbcinst.ini \
    && ldconfig

# openssl 1.0.2 ###############################################################################
# some older db instances uses encryption that's no longer supported openssl 1.1.1+
RUN mkdir /tmp/openssl && cd /tmp/openssl \
    && wget -O openssl.tar.gz https://www.openssl.org/source/old/1.0.2/openssl-1.0.2u.tar.gz \
    && tar xvf openssl.tar.gz \
    && cd openssl-1.0.2u \
    && ./config \
    && make \
    && make install \
    && cd / && rm -rf /tmp/openssl 

