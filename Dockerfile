# We're mixing Node and Nginx Alpine images, to allow custom configuration through environment
# variables (at runtime) - like API_URL!
# ---

# since nginx image is bigger (143 lines), we're starting with it and adding node to it.
# Use an official nginx image
#  from https://github.com/nginxinc/docker-nginx/blob/ddbbbdf9c410d105f82aa1b4dbf05c0021c84fd6/mainline/alpine/Dockerfile
FROM nginx:1.15-alpine


# --
# [start] node:10.9-alpine
#   from https://github.com/nodejs/docker-node/blob/72dd945d29dee5afa73956ebc971bf3a472442f7/10/alpine/Dockerfile
# instead of using "FROM", we're copying the Dockerfile source here.
# "FROM node:10.9-alpine"
# --

ENV NODE_VERSION 14.4

RUN addgroup -g 1000 node \
    && adduser -u 1000 -G node -s /bin/sh -D node \
    && apk add --no-cache \
        libstdc++ \
    && apk add --no-cache --virtual .build-deps \
        binutils-gold \
        curl \
        g++ \
        gcc \
        gnupg \
        libgcc \
        linux-headers \
        make \
        python \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz" \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xf "node-v$NODE_VERSION.tar.xz" \
    && cd "node-v$NODE_VERSION" \
    && ./configure \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && apk del .build-deps \
    && cd .. \
    && rm -Rf "node-v$NODE_VERSION" \
    && rm "node-v$NODE_VERSION.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt

ENV YARN_VERSION 1.9.2

RUN apk add --no-cache --virtual .build-deps-yarn curl gnupg tar \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
  && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && mkdir -p /opt \
  && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
  && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && apk del .build-deps-yarn

# We're not using it's command.
# CMD [ "node" ]

# --
# [end] node:10.9-alpine
# --


# From now on we have both nginx and node (+ yarn) available

# And we end our Dockerfile with nginx Dockerfile last instructions

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]

# lets install dependencies
WORKDIR /app
COPY ./package.json ./app
RUN npm install
COPY . .
CMD ["node", "index.js"]
EXPOSE 80
