#!/bin/sh

tenant=$(cat "`dirname $0`"/../../tenant)
okapi_token=$(cat "`dirname $0`"/../../okapi_token)
okapi_url=$(cat "`dirname $0`"/../../okapi_url)
timestamp=$(date +%Y%m%d_%H%M%S)

# Log directory and output file setup
deleted_record_dir="log_deleted_bound_with_parts"
output_file="${deleted_record_dir}/deleted_ids_${timestamp}.log"
[ ! -d "$deleted_record_dir" ] && mkdir -p "$deleted_record_dir"

# Show record count
response=$(curl -s -X GET -H "x-okapi-tenant: ${tenant}" -H "x-okapi-token: ${okapi_token}" "${okapi_url}/inventory-storage/bound-with-parts?limit=0")
total_records=$(echo "$response" | jq -r '.totalRecords')

# Confirm
read -r -p "Are you sure you want to DELETE ${total_records} bound-with-parts? Type 'y' to proceed: " REPLY
echo
if [ "$REPLY" != "Y" -a "$REPLY" != "y" ]
then
    echo "Operation aborted."
    exit 2
fi

# Fetch one record and delete it until no more found or failure
while true; do
    response=$(curl -s -X GET -H "x-okapi-tenant: ${tenant}" -H "x-okapi-token: ${okapi_token}" "${okapi_url}/inventory-storage/bound-with-parts?limit=1")
    id=$(echo "$response" | jq -r '.boundWithParts[].id')
    if [ -z "$id" ]; then
        echo "Deletion complete. See $output_file for details."
        break
    fi
    echo "Deleting ID: $id"
    response=$(curl -D - -sS -X DELETE -H "x-okapi-tenant: ${tenant}" -H "x-okapi-token: ${okapi_token}" "${okapi_url}/inventory-storage/bound-with-parts/${id}")
    # Check if the deletion was successful and log the ID
    if echo "$response" | head -1 | grep -q " 204 "; then
        echo "$id" >> "$output_file"
    else
        response="Failed to delete $id: $response"
        echo "$response"
        echo "$response" >> "$output_file"
        exit 1
    fi
done
