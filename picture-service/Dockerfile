FROM python:alpine

RUN pip install --no-cache-dir Flask \
  && mkdir /app

ADD app/ app/

WORKDIR /app

# The internal port for the application
EXPOSE 8080

ENTRYPOINT ["python","app.py"]
