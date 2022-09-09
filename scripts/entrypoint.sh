#!/bin/sh

set -e

__err() {
  echo "::error::$1"
  exit 1
}

__debug() {
  echo "::debug::$1"
}



# Validate that required variables are set.
if [ -z ${FATAL_CVSS_SCORE} ]; then
    __err "FATAL_CVSS_SCORE MUST be set"
fi

if [ -z ${IMAGE_ID} ]; then
    __err "IMAGE_ID MUST be set"
fi

# If present, remove the leading 'sha256:' prefix from the image id.
IMAGE_ID=$(echo ${IMAGE_ID} | sed 's/.*://')
__debug "preparing to scan image by id id=${IMAGE_ID}"

QUERY="SELECT *, (CASE WHEN cvss_score/1 >= ${FATAL_CVSS_SCORE} THEN 1 ELSE 0 END) AS fatal FROM vulnerabilities WHERE system_type = 'docker_image' AND system_id = '${IMAGE_ID}' AND verbose = 1"

# Toggle how we run the actual scan based on whether or not the VERBOSE 
# variable is set.
#
# Note: if set output will be _very_ verbose.
mkdir /var/log/osquery
if [ -z ${VERBOSE} ]; then
  /opt/uptycs/osquery/lib/ld-linux \
      --library-path /opt/uptycs/osquery/lib \
      /usr/local/bin/osquery-scan \
      --flagfile=${INPUTS_DIR}/flags/osquery.flags \
      --enroll_secret_path=${INPUTS_DIR}/secrets/uptycs.secret \
      --disable_events \
      --disable-database \
      --config_tls_max_attempts=2 \
      --read_max=300000000 \
      --redirect_stderr=false \
      --compliance_data_in_json=true \
      --json \
      "${QUERY}" $@ > osquery_results.json
else
  /opt/uptycs/osquery/lib/ld-linux \
      --library-path /opt/uptycs/osquery/lib \
      /usr/local/bin/osquery-scan \
      --flagfile=${INPUTS_DIR}/flags/osquery.flags \
      --enroll_secret_path=${INPUTS_DIR}/secrets/uptycs.secret \
      --disable_events \
      --disable-database \
      --config_tls_max_attempts=2 \
      --read_max=300000000 \
      --redirect_stderr=false \
      --compliance_data_in_json=true \
      --verbose \
      --tls_dump \
      --json \
      "${QUERY}" $@ > osquery_results.json
fi

# If any of the osquery results have the "fatal" attribute set to "1" then a 
# package with a CVSS score greater than the specified maximum was detected
# and we will fail the build. Otherwise, echo a success message and exit 
# normally.
if jq -e '[.[] | .fatal == "0" ] | all' osquery_results.json ; then
  echo "SUCCESS"
else
  jq 'del(.[] | select(.fatal == "0"))' osquery_results.json | /usr/local/bin/failure_markdown_format.py >> $GITHUB_STEP_SUMMARY
  __err "FATAL_CVSS_SCORE exceeded"
fi
