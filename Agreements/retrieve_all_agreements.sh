#!/bin/bash

# Initialize variables
page=1
per_page=100
all_data="[]"
data_dir="data"
timestamp=$(date +%Y%m%d_%H%M%S)

# OKAPI information
okapi_token=$(cat "`dirname $0`"/../okapi_token)
okapi_url=$(cat "`dirname $0`"/../okapi_url)
endpoint="/erm/sas"

# Files
temp_file="response_temp.json"
output_file="agreements_${timestamp}.json"

# Function to get the next page
fetch_data() {
    curl --silent --location --header "Cookie: folioAccessToken=$okapi_token" \
        "${okapi_url}${endpoint}?page=$1&perPage=$2" >"$temp_file"
}

# Loop for processing all data records
while :; do
    echo "Fetching data for page $page with $per_page records per page..."

    # API call
    fetch_data "$page" "$per_page"

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

    # Insert data into the array, remove duplicates
    all_data=$(echo "$all_data" "$data" | jq -s 'add | unique_by(.id)')

    # Check if the number of records is less than per_page
    current_batch_size=$(echo "$data" | jq '. | length')
    if [ "$current_batch_size" -lt "$per_page" ]; then
        echo "End reached: The last page contains fewer than $per_page entries."
        break
    fi

    # Increment page
    page=$((page + 1))
done

# Write the entire array to the output file
all_data=$(echo "$all_data" | jq 'unique_by(.id)')
echo "$all_data" >"$output_file"
count=$(cat "$output_file" | jq -r '.[] | [.id] | @tsv' | wc -l)
unique_count=$(cat "$output_file" | jq -r '.[] | [.id] | @tsv' | sort | uniq | wc -l)
echo "$count records have been saved to $output_file ($unique_count are unique)."

# Cleanup
[ ! -d "$data_dir" ] && mkdir -p "$data_dir"

mv "${temp_file}" "${data_dir}"
mv "${output_file}" "${data_dir}"
