#!/bin/sh

if [ -z ${FATAL_CVSS_SCORE} ]; then
    err "FATAL_CVSS_SCORE MUST be set"
fi

if [ -z ${IMAGE_ID} ]; then
    err "IMAGE_ID MUST be set"
fi

INPUTS_DIR=/etc/osquery
SOFTWARE_DIR=/opt/uptycs/osquery
BINARY_DIR=${SOFTWARE_DIR}/bin

mkdir /var/log/osquery

/opt/uptycs/osquery/lib/ld-linux \
    --library-path /opt/uptycs/osquery/lib \
    /usr/local/bin/osquery-scan \
    --flagfile=${INPUTS_DIR}/flags/osquery.flags \
    --disable_events \
    --disable-database \
    --verbose \
    --sysfs_mountpoint=/sys \
    --ebpf_program_location=${BINARY_DIR}/bpf_progs.o \
    --enroll_secret_path=${INPUTS_DIR}/secrets/uptycs.secret \
    --augeas_lenses=${SOFTWARE_DIR}/etc/lenses \
    --ebpf_default_offsets=${SOFTWARE_DIR}/etc/ebpf_offsets.json \
    --database_path=${SOFTWARE_DIR}/osquery.db \
    --syslog_pipe_path=${SOFTWARE_DIR}/syslog_pipe \
    --pidfile=${SOFTWARE_DIR}/var/run/osqueryd.pid \
    --config_tls_max_attempts=2 \
    --read_max=300000000 \
    --redirect_stderr=false \
    --tls_dump \
    "SELECT *, (CASE WHEN cvss_score/1 >= ${FATAL_CVSS_SCORE} THEN 1 ELSE 0 END) AS fatal FROM vulnerabilities WHERE system_type = 'docker_image' AND system_id = '${IMAGE_ID}' AND verbose = 1" $@
