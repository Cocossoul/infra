FROM alpine:3.18.3

RUN apk add --no-cache tini curl
ENTRYPOINT [ "/sbin/tini", "--" ]

COPY config/crontab /crontab

RUN ln -sf /dev/stdout /task.log

WORKDIR /

RUN crontab crontab

CMD ["crond", "-f"]
