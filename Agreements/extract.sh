#!/bin/sh

agreement_json_output="$1"
eisbn_id_file="$2"
agreements_json_filtered_by_eisbn_id="${agreement_uuid}_${timestamp}_${eisbn_id_file}.json"

# Find e-resources in agreement_json_output by e-ISBN
while IFS= read -r eisbn_id || [ "${eisbn_id}" ]; do
    eisbn_id_cleaned=$(echo "${eisbn_id}" | tr -d '\r' | xargs)
    echo "Processing e-ISBN: ${eisbn_id_cleaned}"
    jq --arg eisbn_id "${eisbn_id_cleaned}" '.[] | select(.title.identifiers[]?.identifier.value == $eisbn_id)' "${agreement_json_output}" >> "${agreements_json_filtered_by_eisbn_id}"
done < "${eisbn_id_file}"

agreements_json_filtered_by_eisbn_id_uuid_extract="${agreements_json_filtered_by_eisbn_id}_uuids.txt"

# Extract titleInstance UUID's
jq -r '.title.id' "${agreements_json_filtered_by_eisbn_id}" | sort | uniq > "${agreements_json_filtered_by_eisbn_id_uuid_extract}"