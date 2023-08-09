FROM alpine:3.18.3

RUN apk add --no-cache tini curl
ENTRYPOINT [ "/sbin/tini", "--" ]

COPY config/crontab /crontab

WORKDIR /

RUN crontab crontab

CMD ["crond", "-f"]
