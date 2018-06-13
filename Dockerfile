FROM node:carbon-alpine

ENV CF_CLI_VERSION=6.35.2
ENV NODE_ENV=production

RUN apk add --no-cache \
  ca-certificates \
  wget

RUN wget -q -O - "https://packages.cloudfoundry.org/stable?release=linux64-binary&source=github-rel&version=${CF_CLI_VERSION}" \
  | tar -xzf - -C /usr/bin

WORKDIR /opt/resource

COPY package*.json ./
RUN npm install --only=production

COPY . ./

RUN ln -s ./check.js ./check; ln -s ./in.js ./in; ln -s ./out.js ./out
