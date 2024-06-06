#!/bin/sh

tenant=$(cat "`dirname $0`"/../tenant)
okapi_token=$(cat "`dirname $0`"/../okapi_token)
okapi_url=$(cat "`dirname $0`"/../okapi_url)
timestamp=$(date +%Y%m%d_%H%M%S)

# Check whether the argument for the input file has been specified
if [ "$#" -ne 1 ]; then
    echo "Please enter the file name for the input file with the UUID's."
    exit 1
fi

input_file="$1"
suppress_switch="true"

# Check whether the input file exists
if [ ! -f "${input_file}" ]; then
    echo "The input file '${input_file}' does not exist."
    exit 1
fi

# Output file
output_file="${input_file}_updated_${timestamp}.json"

read -p "Are you sure you want to UPDATE these titleInstances? Then type \"y\" to proceed: " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then

    # Loop through each line in the input file and write the result into file
    while IFS= read -r uuid || [ "${uuid}" ]; do
        uuid_cleaned=$(echo "${uuid}" | tr -d '\r' | xargs)
        echo "Processing UUID: ${uuid}"
        result=$(curl -s -w '\n' -X PUT -d "{ \"suppressFromDiscovery\": ${suppress_switch} }" -H "Content-type: application/json" -H "x-okapi-tenant: ${tenant}" -H "x-okapi-token: ${okapi_token}" "${okapi_url}/erm/titles/${uuid_cleaned}")
        echo "$result" >> "${output_file}"
    done < "$input_file"

    updatedRecordDir="log_updated_records"

    [ ! -d "$updatedRecordDir" ] && mkdir -p "$updatedRecordDir"

    mv ${output_file} ${updatedRecordDir}

    echo "Script completed. See logs in ${updatedRecordDir}."

else
    echo "Operation aborted."

fi



