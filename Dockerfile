FROM uptycs/k8sosquery:5.3.0.10-Uptycs-Protect-202208052028

# Install utilities required to install docker-cli, setup the docker repository
# and finally install the docker-cli.
RUN env && which apt && /usr/bin/apt update && /usr/bin/apt install -y curl gpg lsb-release && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    /usr/bin/apt update && /usr/bin/apt install -y docker-ce-cli

# Copy all of the secrets into the newly built image.
COPY .secret/ca.crt /etc/osquery/ca.crt
COPY .secret/uptycs.secret  /etc/osquery/secrets/uptycs.secret
COPY .secret/osquery.flags /etc/osquery/flags/osquery.flags

COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
