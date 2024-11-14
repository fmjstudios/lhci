#syntax=docker/dockerfile:1.4

# Build arguments
ARG VERSION=0.1.0
ARG NODE_VERSION=20
ARG APP_ENV=prod

# -------------------------------------
# LHCI Base Image
# -------------------------------------
FROM node:${NODE_VERSION}-alpine as base

# container settings
ARG PHP_VERSION
ARG PUID=4501
ARG PGID=4501
ARG PORT=9001
ARG USER=lhci

# persistent / runtime deps
# hadolint ignore=DL3018
RUN apk update && apk add --no-cache --update \
  python3=~3.12 \
  build-base=~0.5 \
  sqlite=~3.45 \
  yq=~4.44 \
  jq=~1.7 \
  trurl

# set default environment variables
ENV PUID=${PUID} \
  PGID=${PGID} \
  PORT=${PORT} \
  APP_ENV=${APP_ENV}

RUN <<EOF
mkdir -p /data
chown -R ${PUID}:${PGID} /data
EOF

COPY --chmod=755 docker/bin/lhctl /usr/local/bin
COPY --chmod=755 docker/bin/lhci /usr/local/bin
COPY --chmod=644 docker/lib/utils.sh /usr/local/lib

# add a healthcheck
# ref: https://developer.shopware.com/docs/guides/hosting/installation-updates/cluster-setup.html#health-check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=5 \
  CMD curl --fail "http://localhost:${PORT:-9001}/healthz" || exit 1

# -------------------------------------
# LHCI Builder Image
# -------------------------------------
FROM base as builder

# (re)-set args
ARG PUID
ARG PGID

WORKDIR /app
COPY package*.json ./
RUN \
  --mount=type=secret,id=npm_auth,dst=./.npmrc \
  --mount=type=cache,target=/root/.npm \
  npm ci

# -------------------------------------
# LHCI Runner Image
# -------------------------------------
FROM base as runner

# (re)-set args
ARG PUID
ARG PGID
ARG USER
ARG PORT

# create groups/users & give access to /data
RUN \
  addgroup -g ${PGID} ${USER}; \
  adduser -D -u ${PUID} -G ${USER} ${USER}; \
  chown -R ${USER}:${USER} /data

# copy sources
WORKDIR /app
COPY --link --chown=${PUID}:${PGID} . ./
COPY --from=builder --chown=${PUID}:${PGID} /app ./

# remove non-ignorable files
RUN \
  rm -rf ./docker

# expose port 9001
EXPOSE ${PORT}

# switch to the lhci user
USER ${USER}

ENTRYPOINT [ "lhctl", "run" ]
