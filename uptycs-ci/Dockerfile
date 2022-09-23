FROM uptycs/k8sosquery:5.3.0.10-Uptycs-Protect-202208052028 AS upstream

FROM ubuntu:20.04 AS ubuntu
WORKDIR /opt/uptycs/osquery/lib
RUN ls /usr/lib/
RUN cp -L /lib*/ld-linux-*64.so.* /opt/uptycs/osquery/lib/ld-linux && \
        cp -L /usr/lib/*64-linux-gnu/libpthread.so.0 \
        /usr/lib/*64-linux-gnu/libz.so.1 \
        /usr/lib/*64-linux-gnu/libdl.so.2 \
        /usr/lib/*64-linux-gnu/librt.so.1 \
        /usr/lib/*64-linux-gnu/libc.so.6 \
        /usr/lib/*64-linux-gnu/libresolv.so.2 \
        /usr/lib/*64-linux-gnu/libm.so.6 \
        /usr/lib/*64-linux-gnu/libnss_dns.so.2 \
        /opt/uptycs/osquery/lib/

FROM alpine:latest

WORKDIR /opt/uptycs/cloud
RUN set -ex;\
    apk update && apk add --no-cache python3 jq su-exec supervisor device-mapper device-mapper-libs gpgme-dev btrfs-progs-dev lvm2-dev 

COPY --from=upstream /etc/osquery/ca.crt /etc/osquery/ca.crt
COPY --from=upstream /usr/bin/osqueryd /usr/local/bin/osquery-scan 
COPY --from=ubuntu /opt/uptycs/osquery/ /opt/uptycs/osquery
COPY scripts/* /usr/local/bin/

RUN mkdir /var/log/osquery && chmod +x /usr/local/bin/osquery-scan

ENTRYPOINT [ "/usr/local/bin/docker-image-scan" ]
