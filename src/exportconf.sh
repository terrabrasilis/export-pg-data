#!/bin/bash
# if you want filter, set the tables names into FILTER variable below and removing the character # to uncomment that.
# FILTER=("table_name_a" "table_name_b" "table_name_c")
#
# Set the output directory for database
OUTPUT_DATA="${OUTPUT_DATA}/${database}"
#
#
# Remove the output files after ZIP
RM_OUT="yes"
#
# Fix geometries before export
FIX="yes"
#
# Export to Shapefile
SHP="yes"
#
# Export to GeoPackage
GPKG="yes"
SAME_FILE="yes"
#
# the selected schema
SCHEMA="public"
#
# to read the tables or views from selected schema
TABLE_TYPE='BASE TABLE'
#TABLE_TYPE='VIEW'
#
# get overwrite parameter values
source ${DATA_DIR}/config/exportconf