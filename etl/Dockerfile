FROM python:3.8-slim

RUN apt-get update && apt-get install -y postgresql-client-15

COPY script.py .

CMD ['python', "script.py"]