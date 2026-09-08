FROM debian:stable-slim

RUN apt update && apt -y upgrade
RUN apt -y install mc nodejs npm php-cli
RUN npm install -g vite

RUN echo "PS1='\[\033[01;33m\]\u \[\033[01;34m\]\w\[\033[00m\] '" >> /root/.bashrc

WORKDIR /app
