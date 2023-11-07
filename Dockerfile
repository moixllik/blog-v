FROM alpine
RUN apk add --no-cache gcompat libatomic
RUN apk add --no-cache openssl
RUN apk add --no-cache mongo-c-driver

WORKDIR webapp
COPY app        .
COPY public     public

ENTRYPOINT ./app