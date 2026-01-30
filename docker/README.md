# Readarr-JM Docker Image

This is a custom fork of Readarr with a configurable book match threshold.

## Features

- Based on LinuxServer.io base image (Alpine)
- Multi-architecture support (amd64 and arm64)
- Configurable book match threshold (default 40%)
- Built from source with latest changes

## Usage

### Docker Compose (recommended)

```yaml
version: "3"
services:
  readarr:
    image: ghcr.io/jmengit/media-readarr_jm:latest
    container_name: readarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
    volumes:
      - ./config:/config
      - /path/to/books:/books
      - /path/to/downloads:/downloads
    ports:
      - 8787:8787
    restart: unless-stopped
```

### Docker CLI

```bash
docker run -d \
  --name=readarr \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/New_York \
  -p 8787:8787 \
  -v /path/to/config:/config \
  -v /path/to/books:/books \
  -v /path/to/downloads:/downloads \
  --restart unless-stopped \
  ghcr.io/jmengit/media-readarr_jm:latest
```

## Parameters

| Parameter | Function |
| :----: | --- |
| `-p 8787` | The port for the Readarr web interface |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=America/New_York` | Specify a timezone to use |
| `-v /config` | Database and Readarr configs |
| `-v /books` | Location of Book library on disk |
| `-v /downloads` | Location of download managers output directory |

## User / Group Identifiers

When using volumes (`-v` flags), permissions issues can arise between the host OS and the container. To avoid this issue, specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify.

## Application Setup

Access the webui at `<your-ip>:8787`.

### Book Match Threshold

This fork includes a configurable book match threshold setting. Navigate to **Settings → Media Management** (enable Advanced Settings) to find the **Book Match Threshold** option. The default is 40% (more lenient than the original 80%).

## Building Locally

```bash
docker build -t readarr-jm ./docker
```

## Tags

- `latest` - Latest stable release
- `develop` - Development branch builds
- `vX.X.X` - Specific version releases
