#!/bin/bash
# Start application.
source /etc/environment
DATA_DIR=$SHARED_DIR
cd $INSTALL_PATH/

LOG="${INSTALL_PATH}/docker-run.log"

for CONF_FILE in `ls $DATA_DIR/config/ | awk {'print $1'}`
do
  # avoid if ${CONF_FILE} is exportconf
  if [[ ! "${CONF_FILE}" = "exportconf" ]];
  then
    /bin/bash ./get_databases.sh "${CONF_FILE}" "${DATA_DIR}" "${INSTALL_PATH}" >> ${LOG}
  fi;
done