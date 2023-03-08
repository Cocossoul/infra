FROM amazoncorretto:17-alpine-full

RUN mkdir -p /server
COPY config/ /server/config/
COPY startup_script.sh /server/
RUN mkdir -p /server/runtime

WORKDIR /server/runtime

ENTRYPOINT /server/startup_script.sh
