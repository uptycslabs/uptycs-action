FROM alpine:latest

RUN apk add --update openssh \
    && ssh-keygen -t rsa -N '' -f /root/.ssh/id_rsa