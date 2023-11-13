## Disclaimer

Use the delete script with extreme caution! Once called and confirmed, all instances listed in the input file, including their holdings, items, and relations will be **deleted** in the given tenant. This is irreversible.

## Determine instance HRIDs

---
**NOTE**

As the instance HRID == the PPN of a K10plus title in GBV, this step can be skipped if a PPN list already exists. Otherwise, proceed as follows.

---

1. First we need a list of instance HRID's. As there is no option in Inventory to export the HRID's from a hit set, we have to take a small detour.
2. Open the Inventory app, search for the results and download a list of instance UUID's via Actions > Save instance UUIDs
3. As a result, a CSV file containing one instance UUID per line is downloaded. Save this file locally.
4. The file can then be further processed with invoking the script [get_instances_by_uuid.sh](get_instances_by_uuid.sh), which downloads the full instance records in JSON format, extracts the instance HRID and saves it in an output file. Run it by calling

```bash
./get_instances_by_uuid.sh <file with instance UUID's>
```

5. After the script ran successfully, it will move the file with the instance UUID's and the JSON file with the full instance records into a subdirectory ```data```. A file with the instance HRID's is stored in the subdirectory ```hrid```.

### Delete instances, their holdings, items and relations

1. Now we're ready to delete the instances by sending a DELETE with the HRID's to ```/inventory-upsert-hrid``` by calling

```bash
./delete_instances_by_hrid.sh <file with instance HRID's>
```

2. You have to confirm the deletion before the request is being processed. The delete process is logged and the logs are written into a subdirectory ```log_deleted_records```.