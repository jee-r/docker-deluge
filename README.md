# docker-deluge
[![Drone (self-hosted)](https://img.shields.io/drone/build/docker/deluge?server=https%3A%2F%2Fdrone.c0de.in&style=flat-square)](https://drone.c0de.in/docker/deluge)
[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/j33r/deluge?style=flat-square)](https://microbadger.com/images/j33r/deluge)
[![MicroBadger Layers](https://img.shields.io/microbadger/layers/j33r/deluge?style=flat-square)](https://microbadger.com/images/j33r/deluge)
[![Docker Pulls](https://img.shields.io/docker/pulls/j33r/deluge?style=flat-square)](https://hub.docker.com/r/j33r/deluge)
[![DockerHub](https://img.shields.io/badge/Dockerhub-j33r/deluge-%232496ED?logo=docker&style=flat-square)](https://hub.docker.com/r/j33r/deluge)

A docker image for [Deluge](https://deluge-torrent.org/) ![deluge's logo](https://user-images.githubusercontent.com/10530469/79228210-5ae36180-7e61-11ea-8f72-276e6197f011.png)


##

## Docker Compose

```
version: '3.8'
services:
  deluge:
    build: .
    image: deluge:latest
    container_name: deluge
    restart: unless-stopped
    user: 1000:1000
    depends_on:
      - proxy
    ports:
      - 8112:8112
      - 58846:58846
    expose:
      - 8112
    labels:
      - "traefik.enable=true"
      - "traefik.port=8112"
      - "traefik.http.services.deluge.loadbalancer.server.port=8112"
      - "traefik.docker.network=tipiak"
      - "traefik.http.routers.deluge.entrypoints=http"
      - "traefik.http.routers.deluge.rule=PathPrefix(`/deluge`)"
      - "traefik.http.routers.deluge.middlewares=deluge-stripprefix"
      - "traefik.http.middlewares.deluge-stripprefix.stripprefix.prefixes=/deluge"
      - "traefik.http.middlewares.deluge-stripprefix.stripprefix.forceslash=false"
    environment:
      - UMASK_SET=022
      - TZ=Europe/Paris
    volumes:
      - ./config:/config
      - ${HOME}/Download:/Download
      - /etc/localtime:/etc/localtime:ro

```
