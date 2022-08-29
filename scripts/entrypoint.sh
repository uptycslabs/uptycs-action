#!/bin/sh

# err() {
#   echo "ERROR: $1"
#   exit 1
# }

# debug() {
#   echo "DEBUG: $1"
# }

# echo "CHROOT_DIR=${CHROOT_DIR}"
# echo "FATAL_CVSS_SCORE=${FATAL_CVSS_SCORE}"
# echo "IMAGE_ID=${IMAGE_ID}"

# if [ ! -d ${CHROOT_DIR} ]; then
#     err "Change root directory ${CHROOT_DIR} is not mounted in the container"
# fi

if [ -z ${FATAL_CVSS_SCORE} ]; then
    err "FATAL_CVSS_SCORE MUST be set"
fi

if [ -z ${IMAGE_ID} ]; then
    err "IMAGE_ID MUST be set"
fi

# # Eg. /host /opt/uptycs/osquery
# DIR=${CHROOT_DIR}${SOFTWARE_DIR}
# debug "DIR=${DIR}"

# # Eg. /host /opt/uptycs/osquery/bin
# debug "BINARY_DIR=${BINARY_DIR}"
# BIN_DIR=${CHROOT_DIR}${BINARY_DIR}
# debug "BIN_DIR=${BIN_DIR}"

# LIB_DIR=${CHROOT_DIR}/lib

# debug "rm -rf ${DIR}/var ${DIR}/tmp"
# rm -rf ${DIR}/var ${DIR}/tmp
# debug "mkdir -p ${DIR}/etc/lenses ${DIR}/logs ${DIR}/bin ${DIR}/var/run ${DIR}/tmp"
# mkdir -p ${DIR}/etc/lenses ${DIR}/logs ${DIR}/bin ${DIR}/var/run ${DIR}/tmp

# cp -LR /usr/share/osquery/lenses \
#     /usr/share/osquery/ebpf_offsets.json \
#     /etc/osquery/ca.crt \
#     /etc/osquery/secrets/uptycs.secret \
#     /etc/osquery/flags/osquery.flags \
#     ${DIR}/etc/

# debug "cp /usr/bin/bpf_progs.o /usr/bin/osqueryd ${BIN_DIR}/"
# cp /usr/bin/bpf_progs.o /usr/bin/osqueryd ${BIN_DIR}/

# debug "mv ${BIN_DIR}/osqueryd ${BIN_DIR}/osquery-scan"
# mv ${BIN_DIR}/osqueryd ${BIN_DIR}/osquery-scan

# debug "chmod -R 700 ${DIR}"
# chmod -R 700 ${DIR}

# debug "chmod -R 600 ${DIR}/etc/*"
# chmod -R 600 ${DIR}/etc/*

# debug "making ${BIN_DIR}/osquery-scan executable..."
# chmod +x "${BIN_DIR}/osquery-scan"

# debug "searching for libpthread.so.0..."
# find / -name "libpthread.so*"

# debug "ls /"
# ls -alh /

# debug "ls /usr"
# ls -alh /usr

# mkdir "${CHROOT_DIR}/lib"
# debug "mounting /usr/lib to ${LIB_DIR}"
# mount --bind /usr/lib "${LIB_DIR}"

# cp /bin/sh ${BIN_DIR}/sh
# chmod +x "${BIN_DIR}/sh"

# debug "chroot-ing to ${CHROOT_DIR} to run ${BINARY_DIR}/osquery-scan"
# ls -alh ${BIN_DIR}

INPUTS_DIR=/etc/osquery
SOFTWARE_DIR=/opt/uptycs/osquery
BINARY_DIR=${SOFTWARE_DIR}/bin

${BINARY_DIR}/osquery-scan \
    --flagfile=${INPUTS_DIR}/flags/osquery.flags \
    --disable_events \
    --disable-database \
    --verbose \
    --sysfs_mountpoint=/sys \
    --ebpf_program_location=${BINARY_DIR}/bpf_progs.o \
    --tls_server_certs=${INPUTS_DIR}/ca.crt \
    --enroll_secret_path=${INPUTS_DIR}/secrets/uptycs.secret \
    --augeas_lenses=${SOFTWARE_DIR}/etc/lenses \
    --ebpf_default_offsets=${SOFTWARE_DIR}/etc/ebpf_offsets.json \
    --database_path=${SOFTWARE_DIR}/osquery.db \
    --syslog_pipe_path=${SOFTWARE_DIR}/syslog_pipe \
    --pidfile=${SOFTWARE_DIR}/var/run/osqueryd.pid \
    --logger_path=${SOFTWARE_DIR}/logs \
    --config_tls_max_attempts=2 \
    --read_max=300000000 \
    --redirect_stderr=false \
    --tls_dump \
    "SELECT *, (CASE WHEN cvss_score/1 >= ${FATAL_CVSS_SCORE} THEN 1 ELSE 0 END) AS fatal FROM vulnerabilities WHERE system_type = 'docker_image' AND system_id = '${IMAGE_ID}' AND verbose = 1"
