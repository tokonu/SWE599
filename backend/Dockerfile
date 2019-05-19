FROM python:3.7-alpine3.8

COPY . /app
WORKDIR /app
ENV FLASK_APP=flaskcli

RUN apk add --no-cache --virtual .build-deps gcc musl-dev
RUN pip install -r requirements.txt
RUN flask db create

EXPOSE 5000

CMD gunicorn --config gunicornconfig.py  wsgi:app