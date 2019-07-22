FROM openjdk@sha256:33f68c6230af30dd104c838f54295a6765b5609c81719be9cf5b24b1e950b899 AS build

ARG VERSION

ENV KAFKA_MANAGER_SRC_DIR=/tmp/kafka-manager-source

RUN mkdir -p $KAFKA_MANAGER_SRC_DIR \
    && wget "https://github.com/yahoo/kafka-manager/archive/${VERSION}.tar.gz" -O kafka-manager-sources.tar.gz \
    && tar -xzf kafka-manager-sources.tar.gz -C $KAFKA_MANAGER_SRC_DIR --strip-components=1 \
    && cd $KAFKA_MANAGER_SRC_DIR \
    && echo 'scalacOptions ++= Seq("-Xmax-classfile-name", "200")' >> build.sbt \
    && ./sbt clean dist \
    && unzip -d ./builded ./target/universal/kafka-manager-${VERSION}.zip \
    && mv -T ./builded/kafka-manager-${VERSION} /kafka-manager \
    && rm -rf $KAFKA_MANAGER_SRC_DIR

FROM openjdk@sha256:f362b165b870ef129cbe730f29065ff37399c0aa8bcab3e44b51c302938c9193

LABEL maintainer="Castle Intelligence, Inc. https://github.com/castle/docker-kafka-manager"

RUN apk update && apk add bash
COPY --from=build /kafka-manager /kafka-manager

WORKDIR /kafka-manager

EXPOSE 9000
ENTRYPOINT ["./bin/kafka-manager", "-Dapplication.home=."]
