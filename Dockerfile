#version nodejs-10.9.0
#version nginx 1.15
FROM pasientskyhosting/nginx-nodejs
#FROM mhart/alpine-node:latest
#FROM mhart/alpine-node:12

#ARG NODE_ENV=production
#ENV $NODE_ENV

# lets install dependencies
WORKDIR /var/www/html/
COPY ./package*.json /var/www/html/
RUN npm install
RUN npm install express
COPY . var/www/html/
#COPY config/nginx.default.conf var/www/html/
CMD service nginx start && npm start
EXPOSE 3000
