#!/bin/bash
if [[ -f "$1" ]];
then
  source "$1"
  export PGPASSWORD=$password
  # Define where postgres binaries is and format the base command
  PG_BIN="/usr/bin"
  PG_CON="-U ${user} -h ${host} -p ${port}"
  DB_CON="-d ${database} ${PG_CON}"
  #
  # filter only database of db name ilike with...for get_databases.sh script
  DB_NAME_LIKE="prodes_%"
else
  echo "Missing Postgres config file."
  exit
fi