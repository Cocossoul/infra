FROM alpine:3.18.3

RUN apk add --no-cache tini lighttpd
ENTRYPOINT [ "/sbin/tini", "--" ]

RUN mkdir -p /var/lib/lighttpd/cache/deflate/ \
    && chown -R lighttpd:lighttpd /var/lib/lighttpd/

COPY lighttpd.conf /etc/lighttpd/lighttpd.conf
COPY www/ /var/www/htdocs/

CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
