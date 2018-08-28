#!/bin/bash

# Uncomment to see all variables used in this script
# set -x;

script_path=`dirname $0`

# fail on any error
set -o errexit
set -o pipefail

export LOG=/tmp/load-data.sh.log

echo "* Load data started. Logging to $LOG" | tee -a $LOG

# Show script name and line number when errors occur to make errors easier to debug
trap 'echo "
! Script error in $0 on or near line ${LINENO}. Check $LOG for details

    To view log:
    cat $LOG | less
"' ERR

cd $script_path/..

# Make app config available as shell variables
if [ ! -f .env ]; then
    cp .env.dist .env
fi
source .env
cd - >> $LOG

export MYSQLCMD="mysql --no-auto-rehash --default-character-set=utf8mb4 --host=$DATABASE_HOST --port=$DATABASE_PORT --user=$DATABASE_USER --password=$DATABASE_PASSWORD"

export EXISTS="0"
echo "SELECT 'Access to database is properly set-up'" | $MYSQLCMD $DATABASE_NAME && \
(

    echo "Database already exists";

    echo "* Dropping all tables and views" | tee -a $LOG;
    cat stack/scripts/drop-all-tables-and-views.sql | $MYSQLCMD $DATABASE_NAME >> $LOG;

) || (

    echo "Database will now be setup";
    echo "* Creating schema" | tee -a $LOG;
    echo "CREATE DATABASE IF NOT EXISTS "\`"$DATABASE_NAME"\`" DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_bin;" | $MYSQLCMD;

)

echo "* Setting schema character set and collation defaults" | tee -a $LOG
echo "ALTER SCHEMA $DATABASE_NAME DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_bin;" | $MYSQLCMD

echo "* Loading the schema" | tee -a $LOG
pv schema.sql | $MYSQLCMD $DATABASE_NAME

echo "* Loading table data: person" | tee -a $LOG
pv data/sql/person.sql | sed 's/\[from\]/`from`/' |$MYSQLCMD $DATABASE_NAME

echo "* Loading table data: dokutskottsforslag" | tee -a $LOG
# the removal of specific lines is necessary due to invalid whitespace that makes the import fail
pv data/sql/bet-2006-2009.sql | sed -e '93559d' | sed -e '251660d' | sed -e '397945d' > data/sql/bet-2006-2009.sql.fixed
pv data/sql/bet-2006-2009.sql.fixed | $MYSQLCMD $DATABASE_NAME
pv data/sql/bet-2010-2013.sql | sed -e '177058d' | sed -e '415341d' | sed -e '551488d' > data/sql/bet-2010-2013.sql.fixed
pv data/sql/bet-2010-2013.sql.fixed | $MYSQLCMD $DATABASE_NAME
pv data/sql/bet-2014-2017.sql | sed -e 's/tumnagel,tumnagel/tumnagel_incorrect_dump,tumnagel/' | sed -e 's/,,,/,NULL,NULL,/' | $MYSQLCMD $DATABASE_NAME

echo "* Loading table data: anforande" | tee -a $LOG
pv data/sql/anforande-200607.sql | $MYSQLCMD $DATABASE_NAME
pv data/sql/anforande-200708.sql | $MYSQLCMD $DATABASE_NAME
pv data/sql/anforande-200809.sql | $MYSQLCMD $DATABASE_NAME
pv data/sql/anforande-200910.sql | $MYSQLCMD $DATABASE_NAME
pv data/sql/anforande-201011.sql | $MYSQLCMD $DATABASE_NAME
pv data/sql/anforande-201112.sql | $MYSQLCMD $DATABASE_NAME
pv data/sql/anforande-201213.sql | $MYSQLCMD $DATABASE_NAME
pv data/sql/anforande-201314.sql | $MYSQLCMD $DATABASE_NAME
pv data/sql/anforande-201415.sql | $MYSQLCMD $DATABASE_NAME
pv data/sql/anforande-201516.sql | $MYSQLCMD $DATABASE_NAME
pv data/sql/anforande-201617.sql | $MYSQLCMD $DATABASE_NAME
pv data/sql/anforande-201718.sql | $MYSQLCMD $DATABASE_NAME

echo "* Loading table data: votering" | tee -a $LOG
pv data/sql/votering-200607.sql | $MYSQLCMD $DATABASE_NAME
pv data/sql/votering-200708.sql | $MYSQLCMD $DATABASE_NAME
pv data/sql/votering-200809.sql | $MYSQLCMD $DATABASE_NAME
pv data/sql/votering-200910.sql | $MYSQLCMD $DATABASE_NAME
pv data/sql/votering-201011.sql | $MYSQLCMD $DATABASE_NAME
pv data/sql/votering-201112.sql | $MYSQLCMD $DATABASE_NAME
pv data/sql/votering-201213.sql | $MYSQLCMD $DATABASE_NAME
pv data/sql/votering-201314.sql | $MYSQLCMD $DATABASE_NAME
pv data/sql/votering-201415.sql | $MYSQLCMD $DATABASE_NAME
pv data/sql/votering-201516.sql | $MYSQLCMD $DATABASE_NAME
pv data/sql/votering-201617.sql | $MYSQLCMD $DATABASE_NAME
pv data/sql/votering-201718.sql | $MYSQLCMD $DATABASE_NAME

# TODO: Correct the schema to be able to import utskottsdokument
#echo "* Loading table data: utskottsdokument" | tee -a $LOG
#pv data/sql/utskottsdokument-2006-2009.sql | $MYSQLCMD $DATABASE_NAME
#pv data/sql/utskottsdokument-2010-2013.sql | $MYSQLCMD $DATABASE_NAME
#pv data/sql/utskottsdokument-2014-2017.sql | $MYSQLCMD $DATABASE_NAME

echo "* Load db finished. Log is found at $LOG"
echo
echo "    To view log:"
echo "    cat $LOG | less -R";
echo
