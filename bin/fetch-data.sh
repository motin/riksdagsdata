#!/bin/bash

# Uncomment to see all variables used in this script
# set -x;

script_path=`dirname $0`

# work in a temporary director
cd /tmp

# ensure pup is installed
which pup
if [ "$?" == "1" ]; then
    wget https://github.com/ericchiang/pup/releases/download/v0.4.0/pup_v0.4.0_linux_amd64.zip
    unzip pup_v0.4.0_linux_amd64.zip
    mv pup /usr/local/bin/
fi

# fail on any error
set -o errexit
set -o pipefail

# fetch data
wget 'https://data.riksdagen.se/data/dokument/' -O dokument.html
cat dokument.html | sed 's/fpm -2010-2013.sql.zip/fpm-2010-2013.sql.zip/' | pup 'a attr{href}' | grep '.sql.zip' > files-to-fetch.txt
wget 'https://data.riksdagen.se/data/ledamoter/' -O ledamoter.html
cat ledamoter.html | pup 'a attr{href}' | grep '.sql.zip' >> files-to-fetch.txt
wget 'https://data.riksdagen.se/data/anforanden/' -O anforanden.html
cat anforanden.html | pup 'a attr{href}' | grep '.sql.zip' >> files-to-fetch.txt
wget 'https://data.riksdagen.se/data/voteringar/' -O voteringar.html
cat voteringar.html | pup 'a attr{href}' | grep '.sql.zip' >> files-to-fetch.txt

cd /app/data/sql
IFS=$'\n'       # make newlines the only separator
for url in $(cat /tmp/files-to-fetch.txt); do
    FILENAME="$(basename $url)"
    FILENAME_WITHOUT_ZIP=${FILENAME/.zip/}
    if [ ! -f "$FILENAME" ] && [ ! -f "$FILENAME_WITHOUT_ZIP" ]; then
        echo "* Downloading file from url: $url"
        wget "https:$url" -O "$FILENAME"
    fi
    if [ -f "$FILENAME" ] && [ ! -f "$FILENAME_WITHOUT_ZIP" ]; then
        unzip -p $FILENAME > $FILENAME_WITHOUT_ZIP
        rm $FILENAME
    fi
done
