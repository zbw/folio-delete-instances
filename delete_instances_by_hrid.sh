#!/bin/sh

tenant=$(cat tenant)
okapi_token=$(cat okapi_token)
okapi_url=$(cat okapi_url)
timestamp=$(date +%Y%m%d_%H%M%S)

# Check whether the argument for the input file has been specified
if [ "$#" -ne 1 ]; then
    echo "Please enter the file name for the input file with the HRID's."
    exit 1
fi

input_file="$1"

# Check whether the input file exists
if [ ! -f "${input_file}" ]; then
    echo "The input file '${input_file}' does not exist."
    exit 1
fi

# Output file
output_file="${input_file}_deleted_${timestamp}.json"

read -p "Are you sure you want to DELETE these instances? Then type \"y\" to proceed: " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then

    # Loop through each line in the input file and write the result into file
    while IFS= read -r hrid || [ "${hrid}" ]; do
        hrid_cleaned=$(echo "${hrid}" | tr -d '\r' | xargs)
        echo "Processing HRID: ${hrid}"
        result=$(curl -s -w '\n' -X DELETE -d "{ \"hrid\": \"${hrid_cleaned}\" }" -H "Content-type: application/json" -H "x-okapi-tenant: ${tenant}" -H "x-okapi-token: ${okapi_token}" "${okapi_url}/inventory-upsert-hrid")
        echo "$result" >> "${output_file}"
    done < "$input_file"

    deletedRecordDir="log_deleted_records"

    [ ! -d "$deletedRecordDir" ] && mkdir -p "$deletedRecordDir"

    mv ${output_file} ${deletedRecordDir}

    echo "Script completed. See logs in ${deletedRecordDir}."

else
    echo "Operation aborted."

fi



