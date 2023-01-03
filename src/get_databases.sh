#!/bin/bash
#
# Used to load database configs.
#
CONF_FILE=${1}
DATA_DIR=${2}
INSTALL_PATH=${3}
# load settings to the each SGDB host.
. "${INSTALL_PATH}/dbconf.sh" "$DATA_DIR/config/$CONF_FILE"

OUTPUT_DATA=$DATA_DIR

ACT_DATE=$(date '+%d-%m-%Y')

PG_FILTER="--tuples-only -P format=unaligned"
PG_QUERY="SELECT datname FROM pg_database WHERE NOT datistemplate AND datname ilike '${DB_NAME_LIKE}';"

if [[ ! -d "${OUTPUT_DATA}/${1}" ]]; then
  # creating output directory to put files
  mkdir -p "${OUTPUT_DATA}/${1}"
fi

OUTPUT_DATA="${OUTPUT_DATA}/${1}"
LOGFILE="${OUTPUT_DATA}/db_exports_${ACT_DATE}.log"

echo "***** GET DATABASES FOR HOST ($ACT_DATE) *****" >> $LOGFILE
for database in `echo -e $PG_QUERY |$PG_BIN/psql --dbname=postgres $PG_CON $PG_FILTER | sed /\eof/p | grep -v rows\) | awk {'print $1'}`
  do
    echo "Run exports to ${database} database at: "$(date '+%d-%m-%YT%H:%M:%S') >> $LOGFILE
    # export to files
    . ./export_tables_to_file.sh
  done