FROM nimlang/nim:latest
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN nimble install --accept yaml
RUN nimble build
RUN nible install
