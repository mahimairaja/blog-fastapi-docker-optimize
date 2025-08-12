# blog-fastapi-docker-optimize

## Build the unoptimized version
```bash
docker build -f Dockerfile-notoptimized -t fastapi-unoptimized .
```

## Run the container
```bash
docker run --rm -p 8000:8000 fastapi-unoptimized:latest
```


## Build the optimized version
```bash
docker build -f Dockerfile -t fastapi-optimized .
```

## Run the container
```bash
docker run --rm -p 8000:8000 fastapi-optimized:latest
```

Read more in the blog check your right side 