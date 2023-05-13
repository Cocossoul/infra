FROM alpine:3.18.0

RUN apk add --no-cache tini python3 py3-pip
ENTRYPOINT [ "/sbin/tini", "--" ]

COPY server/ /server

WORKDIR /server

RUN pip3 install -r requirements.txt

CMD [ "python3", "app.py" ]
