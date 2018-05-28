FROM hseeberger/scala-sbt

ARG VERSION

LABEL maintainer="Castle Intelligence, Inc. https://github.com/castle/docker-kafka-manager"

RUN mkdir -p /tmp
RUN wget -P /tmp https://github.com/yahoo/kafka-manager/archive/${VERSION}.tar.gz
RUN tar xvf /tmp/${VERSION}.tar.gz -C /tmp
RUN cd /tmp/kafka-manager-${VERSION} && sbt clean dist
RUN unzip -d / /tmp/kafka-manager-${VERSION}/target/universal/kafka-manager-${VERSION}.zip
RUN rm -fr /tmp/${VERSION} /tmp/kafka-manager-${VERSION}

WORKDIR /kafka-manager-${VERSION}

EXPOSE 9000
ENTRYPOINT ["./bin/kafka-manager","-Dconfig.file=conf/application.conf"]
