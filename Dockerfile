FROM nimlang/nim:latest
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN nimble install --accept parsetoml
RUN nimble install
RUN nimble build_cli
