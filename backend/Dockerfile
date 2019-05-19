FROM python:3.7-alpine3.8

COPY . /app
WORKDIR /app

RUN apk add --no-cache --virtual .build-deps gcc musl-dev
RUN pip install -r requirements.txt

EXPOSE 5000

CMD gunicorn --config gunicornconfig.py  wsgi:app