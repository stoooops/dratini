# build stage
FROM ubuntu:latest AS build-stage

# install nodejs + npm
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  nodejs \
  npm \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY tsconfig.json .
COPY *.js ./
COPY public ./public
COPY src ./src

RUN npm run build

RUN node --version
RUN npm --version
