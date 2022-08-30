#!/bin/sh

set -ex

err() {
  echo "ERROR: $1"
  exit 1
}

# Validate that required variables are set.
if [ -z ${FATAL_CVSS_SCORE} ]; then
    err "FATAL_CVSS_SCORE MUST be set"
fi

if [ -z ${IMAGE_ID} ]; then
    err "IMAGE_ID MUST be set"
fi

# If present, remove the leading 'sha256:' prefix from the image id.
IMAGE_ID=$(echo ${IMAGE_ID} | sed 's/.*://')

mkdir /var/log/osquery
/opt/uptycs/osquery/lib/ld-linux \
    --library-path /opt/uptycs/osquery/lib \
    /usr/local/bin/osquery-scan \
    --flagfile=${INPUTS_DIR}/flags/osquery.flags \
    --enroll_secret_path=${INPUTS_DIR}/secrets/uptycs.secret \
    --disable_events \
    --disable-database \
    --verbose \
    --config_tls_max_attempts=2 \
    --read_max=300000000 \
    --redirect_stderr=false \
    --tls_dump \
    --compliance_data_in_json=true \
    "SELECT *, (CASE WHEN cvss_score/1 >= ${FATAL_CVSS_SCORE} THEN 1 ELSE 0 END) AS fatal FROM vulnerabilities WHERE system_type = 'docker_image' AND system_id = '${IMAGE_ID}' AND verbose = 1" $@
