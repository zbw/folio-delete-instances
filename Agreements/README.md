# FOLIO update titleInstances in Agreements local KB

## Disclaimer

Use the update script with extreme caution! Once called and confirmed, all titleInstances listed in the input file, will be **updated** in the given tenant.

## Determine titleInstances UUID's

---
**NOTE**

In case you already have a list of titleInstance UUID's you want to update, this step can be skipped. Otherwise, proceed as follows.

---

1. First we need a list of titleInstance UUID's.
2. Open the Agreements app and find the agreement where the package that contains the titleInstance is connected as agreement line. Copy the agreements UUID (e.g. from the URL).
3. Create a file containing the identifiers of the titleInstances where you want to update the ```suppressFromDiscovery``` flag. Currently ZDB-ID and e-ISBN are supported by these scripts.
4. The agreement and its content of e-resources can then be further processed with invoking either the script [retrieve_titleInstance_uuid_by_zdbid.sh](retrieve_titleInstance_uuid_by_zdbid.sh) or [retrieve_titleInstance_uuid_by_eisbn.sh](retrieve_titleInstance_uuid_by_eisbn.sh), which downloads the agreement and all connected e-resources in JSON format, matches e-resources by ZDB-ID's or e-ISBN's provided in an external file and saves the result in an output file. Run it by calling

```bash
./retrieve_titleInstance_uuid_by_zdbid.sh <agreement UUID> <file with ZDB-ID's>
# or
./retrieve_titleInstance_uuid_by_eisbn.sh <agreement UUID> <file with e-ISBN's>
```

5. After the script ran successfully, it will move a bunch of temporary files into a subdirectory ```data```. You can delete those files if you don't wanna keep them for historical reasons.
6. The script will move the file containing the titleInstance UUID's into a subdirectory ```uuid```. You need this file for the next step.

### Update titleInstances

1. Now we're ready to update the titleInstances. You have to specify if you want to set the ```suppressFromDiscovery``` flag to ```true/false``` respectively. Just modify the variable ```suppress_switch``` (false, true) in the update script.
2. You can send a PUT with the UUID's to ```/erm/titles``` by calling

```bash
./update_titleInstance_url_by_uuid.sh <file with titleInstance UUID's>
```

2. You have to confirm the update before the request is being processed. The process is logged and the logs are written into a subdirectory ```log_updated_records```. It contains the JSON respone containing the updated values.
