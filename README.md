Riksdagsdata
============

Scripts and Docker stack configuration for fetching and loading open data from the Swedish parliament (https://data.riksdagen.se/) into a MySQL database locally.

To get started, clone this repository, then start the stack and open a shell:

```
stack/start.sh
stack/shell.sh
```

# Requirements

* Docker
* OSX or Linux (in order to use the stack/*.sh scripts, which sets up the Docker environment)
* About 25 GB available space for the uncompressed data
* Plenty of available disk space in your Docker environment

# Usage

Inside the shell opened by `stack/shell.sh`, the following commands are available:

Fetch the available data:

```
bin/fetch-data.sh
```

This fetches all data that is available in SQL dump files.

Load fetched data into the local MySQL database (replacing all existing database data):

```
bin/load-data.sh
```

Note: Only the data between 2006-2018 for the tables anforande, person, votering and dokutskottsforslag will be loaded. Additional data/tables to be loaded needs to be added to the `bin/load-data.sh` script.

# Why is this needed?

1. The data published on https://data.riksdagen.se/ can now be downloaded all in one swoop instead of file by file.
2. The schema published on https://data.riksdagen.se/dokumentation/databasmodell/ is incorrect in relation with the published data. This project contains a corrected version to allow for import of the data properly.
3. There are various encoding issues related with the original published data which needs some tinkering to get around.
4. (The file fpm-2010-2013.sql.zip is not available on the website due to a broken link.)

# To contribute

Create an issue or send a PR with corrections/improvements.
