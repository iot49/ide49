FROM python:3.10

RUN apt-get update && apt-get install -y \
    nano

COPY requirements.txt /

RUN pip install --upgrade pip \
 && pip install -r /requirements.txt
