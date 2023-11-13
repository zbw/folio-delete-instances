# FOLIO delete instance records in Inventory

## Disclaimer

Use these scripts with extreme caution! Once called and confirmed, records will be **updated** or **deleted** in the given tenant. This is irreversible.

## Use

The scripts require the jq utility to use. All assume you have the following files in the working directory:

- *tenant* -- contains the ID of the FOLIO tenant
- *okapi_url* -- contains the Okapi URL for the tenant
- *okapi_token* -- contains a valid Okapi token

## Authors

- **Felix Hemme** - *Initial work* - [ZBW](https://zbw.eu/de/)

## License

This project is licensed under the Apache License - see the [LICENSE](LICENSE) file for details
