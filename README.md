# docker-deluge

[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/j33r/deluge?style=flat-square)](https://microbadger.com/images/j33r/deluge)
[![Docker Pulls](https://img.shields.io/docker/pulls/j33r/deluge?style=flat-square)](https://hub.docker.com/r/j33r/deluge)
[![DockerHub](https://img.shields.io/badge/Dockerhub-j33r/deluge-%232496ED?logo=docker&style=flat-square)](https://hub.docker.com/r/j33r/deluge)
[![ghcr.io](https://img.shields.io/badge/ghrc%2Eio-jee%2D-r/deluge-%232496ED?logo=github&style=flat-square)](https://ghcr.io/jee-r/deluge)

A docker image for the torrent client [Deluge](https://deluge-torrent.org/) ![deluge's logo](https://user-images.githubusercontent.com/10530469/79228210-5ae36180-7e61-11ea-8f72-276e6197f011.png) based on @emmercm [libtorrent image](https://github.com/emmercm/docker-libtorrent.git). 

# Supported tags

| Tags | Size | Platforms | Build |
|-|-|-|-|
| `latest` | ![](https://img.shields.io/docker/image-size/j33r/deluge/latest?style=flat-square) | `amd64` | ![GitHub Workflow Status (branch)](https://img.shields.io/github/workflow/status/jee-r/docker-deluge/Deploy/master?style=flat-square) |
| `dev` | ![](https://img.shields.io/docker/image-size/j33r/deluge/dev?style=flat-square) |  `amd64` | ![GitHub Workflow Status (branch)](https://img.shields.io/github/workflow/status/jee-r/docker-deluge/Deploy/dev?style=flat-square) |

# What is Deluge?

From [deluge.org](https://www.qbittorrent.org/):

>  Deluge is a fully-featured cross-platform ​BitTorrent client. It is ​Free Software, licensed under the ​GNU GPLv3+ and adheres to ​freedesktop standards enabling it to work across many desktop environments.


# How to use these images

The images do not require any external Docker networks, volumes, environment variables, or arguments and can be run with just:

```bash
docker run \
    --detach \
    --interactive \
    --name deluge \
    --user $(id -u):$(id -g) \
    --volume /etc/localtime:/etc/localtime:ro \
    --env UMASK_SET=022 \
    --env TZ=Europe/Paris \
    #--env LOGLEVEL=info \
    --publish 8112:8112 \
    --publish 58846:58846 \
    ghcr.io/jee-r/deluge:latest
```    

And accessed through the web UI at [http://localhost:8112](http://localhost:8112) with the [default](https://dev.deluge-torrent.org/wiki/UserGuide/Authentication) username `localclient` and password `deluge`.

You can also access through the [Gtk client](https://dev.deluge-torrent.org/wiki/UserGuide/ThinClient) on `localhost` port `58846` for this you will need to set `allow_remote` to `true` in the `config/core.conf` file and [add a new user](https://dev.deluge-torrent.org/wiki/UserGuide/Authentication) `myuser:mypassword:10` in the `config/auth` file.

**Always stop the container before modify your config files otherwise they will not be saved**

## Volume mounts

Due to the ephemeral nature of Docker containers these images provide a number of optional volume mounts to persist data outside of the container:

- `/config`: the Deluge config directory containing `core.conf`
- `/torrents/seed`: the default download location
- `/torrents/leech`: the default incomplete download location
- `/torrents/.watch`: the default autoadd torrent location

```bash
docker run \
    --detach \
    --interactive \
    --name deluge \
    --user $(id -u):$(id -g) \
    --volume ${HOME}/deluge/torrents:/torrents \
    --volume ${HOME}/deluge/config:/config \
    --volume /etc/localtime:/etc/localtime:ro \
    --env UMASK_SET=022 \
    --env TZ=Europe/Paris \
    #--env LOGLEVEL=info \
    --publish 8112:8112 \
    --publish 58846:58846 \
    ghcr.io/jee-r/deluge:latest
```

You should create directory before run the container otherwise directories are created by the docker deamon and owned by the root user

## Environment variables

- `LOGLEVEL`: Set the log level: none, info, warning, error, debug (default: info)
- `TZ`: To change the timezone of the container. The full list of available options can be found on [Wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).

## Docker Compose

[`docker-compose`](https://docs.docker.com/compose/) can help with defining the `docker run` config in a repeatable way rather than ensuring you always pass the same CLI arguments.

Here's an example `docker-compose.yml` config:

```yaml
version: "3"
services:
  deluge:
    image: ghcr.io/jee-r/deluge:latest
    container_name: deluge
    restart: unless-stopped
    user: 1000:1000
    environment:
      - UMASK_SET=022
      - TZ=Europe/Paris
      #- LOGLEVEL=info
    ports:
      - 8112:8112
      - 58846:58846
    volumes:
      - ./config:/config
      - ./torrents:/torrents
      - /etc/localtime:/etc/localtime:ro
```

# License

This project is under the [GNU Generic Public License v3](https://github.com/jee-r/docker-deluge/blob/master/LICENSE) to allow free use while ensuring it stays open.

## Credit

This image is largely inspired by [Christian Emmer](https://emmer.dev)'s great work :

- https://github.com/emmercm/docker-libtorrent
