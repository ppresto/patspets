# picture-service
Simple web service that returns a specific type of picture based on how it was started.

## Build the docker image
```
make build
```

## Run the image
```
docker run -d -p8080:8080 \
-e NAME='dogs' -e VERSION=1 \
ppresto/picture-service
```
The application supports dogs, cats, and rabbits from versions 1-3+
