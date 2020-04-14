# docker-deluge

A docker image for [Deluge](https://deluge-torrent.org/) ![deluge's logo](https://user-images.githubusercontent.com/10530469/79228210-5ae36180-7e61-11ea-8f72-276e6197f011.png)

## docker-compose

```
version: '3.7'

services:

# Torrent 
  deluge:
    build: deluge/build
    image: deluge:latest
    container_name: deluge
    restart: unless-stopped
    depends_on:
      - proxy
    networks:
      - tipiak
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
      #- "traefik.http.middlewares.deluge-headers.headers.customRequestHeaders.X-Deluge-Base=/deluge/"
      #- "traefik.http.middlewares.deluge-headers.headers.customResponseHeaders.X-Deluge-Base=/deluge/"
      #- "traefik.http.routers.deluge.middlewares=deluge-headers"
      - "traefik.http.routers.deluge.middlewares=deluge-stripprefix"
      - "traefik.http.middlewares.deluge-stripprefix.stripprefix.prefixes=/deluge"
      - "traefik.http.middlewares.deluge-stripprefix.stripprefix.forceslash=false"
    environment:
      - UMASK_SET=022
      - TZ=Europe/Paris
    volumes:
      - ./deluge/config:/config
      - /volume1/Media:/Media
      - /volume1/torrents:/torrents
      - /etc/localtime:/etc/localtime:ro

```
