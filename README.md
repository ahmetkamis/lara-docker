# lara-docker

Simple Docker container configuration for Laravel 8 using Nginx and PHP (FPM) 8 for deployment purposes.

Copy `Dockerfile` and `docker`  folder into the Laravel folder and build.

## Build
    docker build -t ahmetkamis/lara-docker .

## RUN
    docker run -d --name=laravel -p 8000:80 ahmetkamis/lara-docker .

## App URL
    http://localhost:8000/