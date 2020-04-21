# openjdk:15-buster
FROM openjdk@sha256:bec9422b2a1cdef0e233967ae515ca60635437eb178a17e910d3c27cdc951511 AS build

ARG VERSION

ENV KAFKA_MANAGER_SRC_DIR=/tmp/kafka-manager-source

RUN mkdir -p $KAFKA_MANAGER_SRC_DIR \
    && wget "https://github.com/yahoo/kafka-manager/archive/${VERSION}.tar.gz" -O kafka-manager-sources.tar.gz \
    && tar -xzf kafka-manager-sources.tar.gz -C $KAFKA_MANAGER_SRC_DIR --strip-components=1 \
    && cd $KAFKA_MANAGER_SRC_DIR \
    && echo 'scalacOptions ++= Seq("-Xmax-classfile-name", "200")' >> build.sbt \
    && ./sbt clean dist \
    && unzip -d ./builded ./target/universal/cmak-${VERSION}.zip \
    && mv -T ./builded/cmak-${VERSION} /kafka-manager \
    && rm -rf $KAFKA_MANAGER_SRC_DIR

# openjdk:15-alpine
FROM openjdk@sha256:477d0b3406e8bb54bf1852f21acf908c7f43c37b3bcdf65bb6709cd71caad4cf

LABEL maintainer="Castle Intelligence, Inc. https://github.com/castle/docker-kafka-manager"

RUN apk update && apk add bash
COPY --from=build /kafka-manager /kafka-manager

WORKDIR /kafka-manager

EXPOSE 9000
ENTRYPOINT ["./bin/kafka-manager", "-Dapplication.home=."]
