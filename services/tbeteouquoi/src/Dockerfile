FROM alpine:3.19.0

RUN apk add --no-cache tini python3 py3-flask
ENTRYPOINT [ "/sbin/tini", "--" ]

COPY server/ /server

WORKDIR /server

EXPOSE 8080

CMD [ "python3", "app.py" ]
