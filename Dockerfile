FROM node:alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY  . .
RUN npm run build

FROM nginx:latest
WORKDIR /usr/share/nginx/html		
COPY --from=base /app/build ./

