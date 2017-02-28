FROM nimlang/nim:latest
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN nim compile secureEnv.nim
