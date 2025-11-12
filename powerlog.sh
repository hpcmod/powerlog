#!/bin/bash
# this script dumps the squeue output to a local file resource_name/year/month/YYYY-MM-DD.log
# cron job runs every 1 minute


script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd ${script_dir}
resource_name="fj-aox01"
archive_dir="${script_dir}/${resource_name}"

date_y=$(date +%Y)
date_m=$(date +%m)
date_ymd=$(date +%Y-%m-%d)
output_dir="${archive_dir}/${date_y}/${date_m}"
output_file="${output_dir}/${date_ymd}.log"
# make sure the directory exists
mkdir -p "${output_dir}"

new_archive=false
if [ ! -f "${output_file}" ]; then
    echo "collected_at,instant_watts,minimum_watts,maximum_watts,average_watts,ipmi_timestamp,sampling_seconds,state" > "${output_file}"
    new_archive=true
fi

function get_power_reading {  
    if ! sudo ipmitool dcmi power reading | awk '
    BEGIN { FS = ":[[:space:]]*" }
    /Instantaneous power reading/ {
        instant = $2
        sub(/[[:space:]]*Watts$/, "", instant)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", instant)
    }
    /Minimum during sampling period/ {
        min = $2
        sub(/[[:space:]]*Watts$/, "", min)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", min)
    }
    /Maximum during sampling period/ {
        max = $2
        sub(/[[:space:]]*Watts$/, "", max)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", max)
    }
    /Average power reading over sample period/ {
        avg = $2
        sub(/[[:space:]]*Watts$/, "", avg)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", avg)
    }
    /IPMI timestamp/ {
        ipmi = $2
        if ($3 != "") ipmi = ipmi ":" $3
        if ($4 != "") ipmi = ipmi ":" $4
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", ipmi)
    }
    /Sampling period/ {
        sampling = $2
        sub(/[[:space:]]*Seconds\.$/, "", sampling)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", sampling)
    }
    /Power reading state/ {
        state = $2
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", state)
    }
    END {
        if (instant == "" || min == "" || max == "" || avg == "" || ipmi == "" || sampling == "" || state == "")
            exit 1
        collected = strftime("%Y-%m-%dT%H:%M:%S%z")
        gsub(/"/, "\"\"", ipmi)
        printf "%s,%s,%s,%s,%s,\"%s\",%s,%s\n", collected, instant, min, max, avg, ipmi, sampling, state
    }
    ' >> "${output_file}"; then
        echo "Failed to log power reading" >&2
        exit 1
    fi
}

get_power_reading
