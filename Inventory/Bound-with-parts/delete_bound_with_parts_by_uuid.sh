#!/bin/sh

tenant=$(cat "`dirname $0`"/../../tenant)
okapi_token=$(cat "`dirname $0`"/../../okapi_token)
okapi_url=$(cat "`dirname $0`"/../../okapi_url)
timestamp=$(date +%Y%m%d_%H%M%S)

# Log directory and output file setup
deletedRecordDir="log_deleted_bound_with_parts"
output_file="${deletedRecordDir}/deleted_ids_${timestamp}.log"
[ ! -d "$deletedRecordDir" ] && mkdir -p "$deletedRecordDir"

# Fetching IDs
echo "Fetching IDs..."
offset=0
limit=100
total_records=1 # Run loop at least once until the exact number of records is known 
id_list=()

while [ $offset -lt $total_records ]; do
    response=$(curl -s -X GET -H "x-okapi-tenant: ${tenant}" -H "x-okapi-token: ${okapi_token}" "${okapi_url}/inventory-storage/bound-with-parts?limit=${limit}&offset=${offset}")
    ids=$(echo "$response" | jq -r '.boundWithParts[].id')
    id_list+=($ids)
    current_count=$(echo "$ids" | wc -w)
    total_records=$(echo "$response" | jq -r '.totalRecords')
    offset=$((offset + limit))
    echo "Processed $current_count from $offset of $total_records records"
    #echo "Processed $offset / $total_records"
done

# Deleting IDs
read -p "Are you sure you want to DELETE these instances? Type 'y' to proceed: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    for id in "${id_list[@]}"; do
        echo "Deleting ID: $id"
        delete_result=$(curl -s -X DELETE -H "x-okapi-tenant: ${tenant}" -H "x-okapi-token: ${okapi_token}" "${okapi_url}/inventory-storage/bound-with-parts/${id}")
        # Check if the deletion was successful and log the ID
        if [[ "$delete_result" == *'204 No Content'* ]]; then
            echo "$id" >> "$output_file"
        else
            echo "Failed to delete $id: $delete_result" >> "$output_file"
        fi
    done
    echo "Deletion complete. See $output_file for details."
else
    echo "Operation aborted."
fi