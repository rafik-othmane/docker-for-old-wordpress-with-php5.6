#!/bin/bash

DATASETS_DIRPATH="/datasets"

MYSQL_COMMAND="mysql -u root -p${MYSQL_ROOT_PASSWORD}"

# Create databases
${MYSQL_COMMAND} < "${DATASETS_DIRPATH}/01-create-database.db.sql"

