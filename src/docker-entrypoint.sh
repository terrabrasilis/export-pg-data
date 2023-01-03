#!/bin/sh
# Start application.
#!/bin/bash
source /etc/environment
DATA_DIR=$SHARED_DIR
cd $INSTALL_PATH/

LOG="${INSTALL_PATH}/docker-run.log"

for CONF_FILE in `ls $DATA_DIR/config/ | awk {'print $1'}`
do
  # avoid if exportconf file
  if [[ ! -f "${DATA_DIR}/config/exportconf" ]];
  then
    /bin/bash ./get_databases.sh "${CONF_FILE}" "${DATA_DIR}" "${INSTALL_PATH}" >> ${LOG}
  fi;
done