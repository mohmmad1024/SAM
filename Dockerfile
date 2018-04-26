FROM openjdk:8-jre
LABEL maintainer="Mohammed alsahli <mohmmad1024@gmail.com>"

ARG SAM_VERSION=0.6.0
ARG DOWNLOAD_URL=https://github.com/hortonworks/streamline/releases/download/v${SAM_VERSION}/hortonworks-streamline-${SAM_VERSION}.zip

ENV BASE_DIR /sam 

# Setup NiFi user
RUN mkdir -p ${BASE_DIR}\
    && curl -fSL ${DOWNLOAD_URL} -o sam.zip \
    && unzip -j sam.zip
    && rm sam.zip

EXPOSE 8080 8081

WORKDIR ${NIFI_HOME}

ADD . ${BASE_DIR}/scripts/

# Apply configuration and start NiFi
CMD ${BASE_DIR}/bin/streamline-server-start.sh -deamon ${BASE_DIR}/conf/streamline.yaml
