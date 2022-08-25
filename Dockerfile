FROM uptycs/k8sosquery:5.3.0.10-Uptycs-Protect-202208052028

# Install utilities required to install docker-cli, setup the docker repository
# and finally install the docker-cli.
RUN rpm install --force docker-ce-cli

# Copy all of the secrets into the newly built image.
COPY .secret/ca.crt /etc/osquery/ca.crt
COPY .secret/uptycs.secret  /etc/osquery/secrets/uptycs.secret
COPY .secret/osquery.flags /etc/osquery/flags/osquery.flags

COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
