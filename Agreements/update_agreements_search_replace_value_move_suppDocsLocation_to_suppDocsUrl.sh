#!/bin/bash

# Initialize variables
search="http://zbwintern/jira"
replace="https://zbw.atlassian.net"
timestamp=$(date +%Y%m%d_%H%M%S)

# OKAPI information
okapi_token=$(cat "$(dirname $0)"/../okapi_token)
okapi_url=$(cat "$(dirname $0)"/../okapi_url)
endpoint="erm/sas"

# Files
# Files
data_file=$1
if [[ -z "$data_file" ]]; then
    echo "Error: No input file provided. Usage: $0 <data_file>"
    exit 1
fi
data_file_replaced="${data_file}_replaced.json"
data_file_replaced_url="${data_file_replaced}_with_url.json"
data_file_replaced_matched="${data_file_replaced}_matched.json"
uuid_file="data/uuids.txt"
data_dir="data"
records_dir="data/records"

# Step 1: Search and replace values in .supplementaryDocs[].location field
jq --arg search "$search" --arg replace "$replace" \
    'map(.supplementaryDocs |= map(if .location != null then .location |= gsub($search; $replace) else . end))' \
    "$data_file" > "$data_file_replaced"
echo "Step 1: Replaced file created: $data_file_replaced"

# Step 2: Move the value from location to url
jq 'map(.supplementaryDocs |= map(if .location != null then .url = .location | .location = null else . end))' \
    "$data_file_replaced" > "${data_file_replaced_url}"
data_file_replaced="${data_file_replaced_url}"
echo "Step 2: Moved location to url. Updated file: $data_file_replaced"

# Step 3: Filter all records that have been touched in step 1
jq --arg replace "$replace" \
    'map(select(.supplementaryDocs[] | any(.url?; . != null and test($replace; "i"))))' \
    "$data_file_replaced" > "$data_file_replaced_matched"
echo "Step 2: Filtered matched records: $data_file_replaced_matched"

# Step 4: Split into separate files, one per record
jq -c '.[]' "$data_file_replaced_matched" | nl -nln | while read -r index json; do
    mkdir -p "${records_dir}"
    echo "$json" > "${records_dir}/record_${index}.json"
done
echo "Step 3: Split files created for each matched record."

read -p "Are you sure you want to UPDATE these agreements? Then type \"y\" to proceed: " -n 1 -r
echo # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then

    # Step 5: PUT to API
    for json_file in "${records_dir}"/*.json; do
        uuid=$(jq -r '.id' "$json_file")
        if [[ -z "$uuid" ]]; then
            echo "Error: No UUID found in the file $json_file."
            continue
        fi
        echo "Processing file $json_file with UUID $uuid"

        echo "Endpoint: ${okapi_url}/${endpoint}"
        echo "Request: ${okapi_url}/${endpoint}/${uuid}"

        curl -s --location --request PUT "${okapi_url}/${endpoint}/${uuid}" \
            --header "Cookie: folioAccessToken=${okapi_token}" \
            --header "Content-Type: application/json" \
            --data @"$json_file"

        echo "PUT request sent for UUID $uuid."

    done

else
    echo "Operation aborted."

fi
