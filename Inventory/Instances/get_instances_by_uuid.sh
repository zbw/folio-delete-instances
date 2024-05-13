#!/bin/bash

tenant=$(cat "`dirname $0`"/../../tenant)
okapi_token=$(cat "`dirname $0`"/../../okapi_token)
okapi_url=$(cat "`dirname $0`"/../../okapi_url)
timestamp=$(date +%Y%m%d_%H%M%S)

# Check whether the argument for the input file has been specified
if [ "$#" -ne 1 ]; then
    echo "Please enter the file name for the input file with the UUID's."
    exit 1
fi

input_file="$1"

# Check whether the input file exists
if [ ! -f "${input_file}" ]; then
    echo "The input file '${input_file}' does not exist."
    exit 1
fi

# Output file
output_file="${input_file}_instances_${timestamp}.json"

# Loop through each line in the input file and write the result into file
while IFS= read -r uuid || [ "${uuid}" ]; do
    echo "Processing UUID: ${uuid}"
    result=$(curl -s -w '\n' -X GET -D -H "Accept: application/json" -H "X-Okapi-Tenant: ${tenant}" -H "x-okapi-token: ${okapi_token}" "${okapi_url}/instance-storage/instances/${uuid}")
    echo "${result}" >> "${output_file}"
done < "${input_file}"

# HRID file
hrid_file="${output_file}_hrids.txt"

# Extract HRID's and write into file
echo "Extracting instance HRID's"
jq -r '.hrid' ${output_file} > ${hrid_file}

data_dir="data"
hrid_dir="hrid"

[ ! -d "$data_dir" ] && mkdir -p "$data_dir"
[ ! -d "$hrid_dir" ] && mkdir -p "$hrid_dir"

mv ${input_file} ${data_dir}
mv ${output_file} ${data_dir}
mv ${hrid_file} ${hrid_dir}

echo "Script completed. See instance HRID's in file ${hrid_dir}/${hrid_file}"
