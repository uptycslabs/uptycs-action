#!/bin/sh

apk add --update bash

/usr/local/bin/docker-image-scan "$@"
