# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.21

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Readarr-JM version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="jmengit"

# environment settings
ENV XDG_CONFIG_HOME="/config/xdg" \
  COMPlus_EnableDiagnostics=0 \
  TMPDIR=/run/readarr-temp

RUN \
  echo "**** install packages ****" && \
  apk add -U --upgrade --no-cache \
    icu-libs \
    sqlite-libs \
    xmlstarlet && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# copy pre-built application
COPY app/readarr/bin /app/readarr/bin

# Remove the update component (not needed in docker)
RUN rm -rf /app/readarr/bin/Readarr.Update 2>/dev/null || true

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8787

VOLUME /config
