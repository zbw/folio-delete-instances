#!/bin/bash

# Initialize variables
offset=0
batch_size=10
all_data="[]"
data_dir="data"
timestamp=$(date +%Y%m%d_%H%M%S)

# OKAPI information
okapi_token=$(cat "`dirname $0`"/../okapi_token)
okapi_url=$(cat "`dirname $0`"/../okapi_url)
endpoint="/licenses/licenses"

# Files
temp_file="response_temp.json"
output_file="licenses_${timestamp}.json"


# Function to get the next page
fetch_data() {
    curl --silent --location --header "Cookie: folioAccessToken=$okapi_token" "${okapi_url}${endpoint}?offset=$1" >"$temp_file"
}

# Loop for processing all data records
while :; do
    echo "Get data with offset $offset..."

    # API call
    fetch_data "$offset"

    # Check whether the answer is valid
    if ! jq empty "$temp_file" 2>/dev/null; then
        echo "Invalid JSON response received, aborting!"
        break
    fi

    # Extract the array from the response
    data=$(jq '.' "$temp_file")

    # Check whether the array is empty
    if [ "$(echo "$data" | jq '. | length')" -eq 0 ]; then
        echo "No further data found."
        break
    fi

    # Insert data into the array
    all_data=$(echo "$all_data" "$data" | jq -s 'add')

    # Increase offset
    offset=$((offset + batch_size))
done

# Write the entire array to the output file
echo "$all_data" >"$output_file"
count=$(cat "$output_file" | jq -r '.[] | [.id] | @tsv' | wc -l)
echo "$count records have been saved to $output_file."

# Cleanup
[ ! -d "$data_dir" ] && mkdir -p "$data_dir"

mv "${temp_file}" "${data_dir}"
mv "${output_file}" "${data_dir}"