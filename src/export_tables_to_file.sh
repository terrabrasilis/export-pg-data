#!/bin/bash

# load exporting configurations
. ./exportconf.sh

# redefine for each db
DB_CON="-d ${database} ${PG_CON}"

if [[ ! "${TABLE_SUFFIX}" = "" ]]; then
    SQL_NOT=""
    if [[ "${AVOID_TABLE_SUFFIX}" = "yes" ]]; then
        SQL_NOT="NOT"
    fi;
    SQL_AND=" AND ${SQL_NOT} table_name ILIKE '%${TABLE_SUFFIX}'"
fi;

SQL_TABLES="select table_name from information_schema.tables where table_schema = '${SCHEMA}'"
SQL_TABLES="${SQL_TABLES} and table_type = '${TABLE_TYPE}' and table_name NOT IN ('geometry_columns','geography_columns','spatial_ref_sys');"

TABLES=($(${PG_BIN}/psql ${DB_CON} -t -c "${SQL_TABLES}"))

fix_geom(){
    TB="$1"
    SQL="UPDATE ${TB} SET geom=ST_MakeValid(geom) WHERE NOT ST_IsValid(geom);"
    if [[ "${FIX}" = "yes" ]]; then
        echo "run the geometry fix query"
        ${PG_BIN}/psql ${DB_CON} -t -c "${SQL}"
    fi;
}

export_shp(){
    SQL="$1"
    TB="$2"
    if [[ "${SHP}" = "yes" ]]; then
        echo "run SHP exportation function"
        pgsql2shp -k -f "${OUTPUT_DATA}/${TB}" -h ${host} -p ${port} -u ${user} ${database} "${SQL}"
        zip -j "${OUTPUT_DATA}/${TB}.zip" "${OUTPUT_DATA}/${TB}.shp" "${OUTPUT_DATA}/${TB}.shx" "${OUTPUT_DATA}/${TB}.prj" "${OUTPUT_DATA}/${TB}.dbf" "${OUTPUT_DATA}/${TB}.cpg"
    fi;
}

export_gpkg(){
    # https://gis.stackexchange.com/questions/327958/ogr2ogr-write-multiple-layers-to-one-geopackage
    # https://gdal.org/programs/ogr2ogr.html#cmdoption-ogr2ogr-update
    # -append (insert new data to the same layer)(insere novos dados na mesma camada) 
    # -update (open the existing file, in update mode, to create a new layer named by the -nln parameter value.)
    SQL="$1"
    TB="$2"
    FNAME="${TB}"
    CONN="host=${host} dbname=${database} port=${port} user=${user} password=${password}"
    if [[ "$GPKG" = "yes" ]]; then
        echo "run GPKG exportation function"
        if [[ "$SAME_FILE" = "yes" ]]; then
            FNAME="${database}"
            if [[ -f "${OUTPUT_DATA}/${FNAME}.gpkg" ]]; then
                ogr2ogr -f "GPKG" ${OUTPUT_DATA}/${FNAME}.gpkg -nln "${TB}" PG:"${CONN}" -update -sql "${SQL}"
            else
                ogr2ogr -f "GPKG" ${OUTPUT_DATA}/${FNAME}.gpkg -nln "${TB}" PG:"${CONN}" -sql "${SQL}"
            fi;
        else
            ogr2ogr -f "GPKG" ${OUTPUT_DATA}/${FNAME}.gpkg -nln "${TB}" PG:"${CONN}" -sql "${SQL}" 
        fi;
        zip -j "${OUTPUT_DATA}/${FNAME}.gpkg.zip" ${OUTPUT_DATA}/${FNAME}.gpkg
    fi;
}

# base query....
# To skip FID column generation in GPKG, use full column list in SQL and map uid to fid column name
if [[ "$GPKG" = "yes" ]]; then
    COLUMNS="uid as fid, geom, state, path_row, main_class, class_name, def_cloud, julian_day, image_date, year, area_km, scene_id, source, satellite, sensor, uuid"
else
    COLUMNS="*"
fi;

for TABLE in ${TABLES[@]}
do
    echo "Do for ${TABLE} table..."

    DATA_QUERY="SELECT ${COLUMNS} FROM ${SCHEMA}.${TABLE}"
    if [[ ${#FILTER[@]} -gt 0 ]]; then
        echo "Has filter by table name"
        if [[ " ${FILTER[@]} " =~ " ${TABLE} " ]]; then
            fix_geom "${TABLE}"
            export_shp "${DATA_QUERY}" "${TABLE}"
            export_gpkg "${DATA_QUERY}" "${TABLE}"
        fi
    else
        fix_geom "${TABLE}"
        export_shp "${DATA_QUERY}" "${TABLE}"
        export_gpkg "${DATA_QUERY}" "${TABLE}"
    fi
done

echo "remove intermediate files"
if [[ "${RM_OUT}" = "yes" ]]; then
    if [[ "${SHP}" = "yes" ]]; then
        rm -f ${OUTPUT_DATA}/*.{shp,shx,prj,dbf,cpg}
    fi
    if [[ "$GPKG" = "yes" ]]; then
        rm -f ${OUTPUT_DATA}/*.gpkg
    fi
fi