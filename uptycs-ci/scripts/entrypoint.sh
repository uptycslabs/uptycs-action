#!/bin/sh

set -e

###############################################################################
# Log an error message that will propagate to the Github Action UI as an error
# message, then proceed to exit with a code of 1 to fail the build.
#
# For additional information see the Workflow Command docs:
# https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message
#
# Arguments:
#   $1: The message to be logged.
###############################################################################
__err() {
  echo "::error::$1"
  exit 1
}

###############################################################################
# Log a debug message that will propagate to the Github Action UI as a debug
# message, if debug logging is enabled for the Github Action.
#
# For additional information see the Workflow Command docs:
# https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-a-debug-message
#
# Arguments:
#   $1: The message to be logged.
###############################################################################
__debug() {
  echo "::debug::$1"
}

###############################################################################
# Generate a URL to the specific commit that is being built against.
#
# The following globals are defined and set by Github. For additional 
# information see: 
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
#
# Globals:
#   GITHUB_SERVER_URL - The URL of the GitHub server that contains the current
#                       repository.
#   GITHUB_REPOSITORY - The owner and repository name combined.
#   GITHUB_SHA        - The commit SHA that triggered the workflow. The value 
#                       of this commit SHA depends on the event that triggered 
#                       the workflow.
###############################################################################
github_sha_url() {
  echo "${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}"
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
      --origin-id=$(github_sha_url) \
      --origin="github" \
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
      --origin-id=$(github_sha_url) \
      --origin="github" \
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
