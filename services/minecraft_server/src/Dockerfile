FROM amazoncorretto:21-alpine-full

RUN apk add --no-cache tini
ENTRYPOINT [ "/sbin/tini", "--" ]

RUN mkdir -p /server
COPY config/ /server/config/
COPY startup_script.sh /server/
RUN mkdir -p /server/runtime

WORKDIR /server/runtime

CMD [ "/server/startup_script.sh" ]
