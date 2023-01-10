#!/bin/bash
#
# Used to load database host configs.
#
CONF_FILE=${1}
DATA_DIR=${2}
INSTALL_PATH=${3}
echo "load settings to the SGDB host."
. "${INSTALL_PATH}/dbconf.sh" "$DATA_DIR/config/$CONF_FILE"

ACT_DATE=$(date '+%d-%m-%Y')

PG_FILTER="--tuples-only -P format=unaligned"
PG_QUERY="SELECT datname FROM pg_database WHERE NOT datistemplate AND datname ilike '${DB_NAME_LIKE}';"

if [[ ! -d "${DATA_DIR}/${1}" ]]; then
  echo "creating output directory to put files"
  mkdir -p "${DATA_DIR}/${1}"
fi

LOGFILE="${DATA_DIR}/${1}/db_exports_${ACT_DATE}.log"

echo "***** GET DATABASES FOR HOST ${host} *****" >> $LOGFILE
for database in `echo -e $PG_QUERY |$PG_BIN/psql --dbname=postgres $PG_CON $PG_FILTER | sed /\eof/p | grep -v rows\) | awk {'print $1'}`
  do
    echo "Run exports to ${database} database at: "$(date '+%d-%m-%YT%H:%M:%S') >> $LOGFILE
    #
    # Set the output directory for database
    OUTPUT_DATA="${DATA_DIR}/${1}/${database}"
    if [[ ! -d "${OUTPUT_DATA}" ]]; then
      echo "creating output directory to current database: ${database}"
      mkdir -p "${OUTPUT_DATA}"
    fi;
    # export to files
    . ./export_tables_to_file.sh >> $LOGFILE
  done