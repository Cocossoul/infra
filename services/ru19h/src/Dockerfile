FROM python:3.11.5-alpine3.18

RUN apk add --no-cache tini curl
ENTRYPOINT [ "/sbin/tini", "--" ]

COPY app /app

WORKDIR /app

RUN pip install -r requirements.txt

CMD ["python3", "main.py"]
