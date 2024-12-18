#!/bin/sh

tenant=$(cat "$(dirname $0)"/../tenant)
okapi_token=$(cat "$(dirname $0)"/../okapi_token)
okapi_url=$(cat "$(dirname $0)"/../okapi_url)
timestamp=$(date +%Y%m%d_%H%M%S)

# Agreement UUID
agreement_uuid="$1"

# Check whether the arguments (agreement_uuid and eisbn_id_file) have been specified
if [ "$#" -ne 2 ]; then
    echo "Please enter the agreement UUID."
    exit 1
fi

agreement_json_output="${agreement_uuid}_${timestamp}.json"

# Agreement export API
# /erm/sas/resources/export
echo "Exporting agreement ..."
agreement_uuid_cleaned=$(echo "${agreement_uuid}" | tr -d '\r' | xargs)
agreement_json=$(curl -s -w '\n' -H "Content-type: application/json" -H "x-okapi-tenant: ${tenant}" -H "x-okapi-token: ${okapi_token}" "${okapi_url}/erm/sas/${agreement_uuid_cleaned}/resources/export")
echo "$agreement_json" >"${agreement_json_output}"

# Check if the JSON is valid
if ! echo "$agreement_json" | jq . > /dev/null 2>&1; then
    echo "Error: Invalid JSON received from server"
    exit 1
fi
echo "$agreement_json" >"${agreement_json_output}"

# File with eISBN's
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

dataDir="data"
uuidDir="uuid"

[ ! -d "$dataDir" ] && mkdir -p "$dataDir"
[ ! -d "$uuidDir" ] && mkdir -p "$uuidDir"


mv ${agreement_json_output} ${dataDir}
mv ${eisbn_id_file} ${dataDir}
mv ${agreements_json_filtered_by_eisbn_id} ${dataDir}
mv ${agreements_json_filtered_by_eisbn_id_uuid_extract} ${uuidDir}
