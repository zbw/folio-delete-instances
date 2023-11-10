# FOLIO delete instance records in Inventory

# Disclaimer

Use the delete script with extrem caution! Once called and confirmed, all instances listed in the input file, including their holdings, items, and relations will be **deleted** in the given tenant.

# Use

Most scripts here require the jq utility to use. All assume you have the following files in the working directory:

- *tenant* -- contains the ID of the FOLIO tenant
- *okapi_url* -- contains the Okapi URL for the tenant
- *okapi_token* -- contains a valid Okapi token
