#!/bin/sh

set -e
set -u

DB=${1:-test_euler}

dropdb --if-exists ${DB}
createdb ${DB}
psql -1 ${DB} < eulerian_path.sql 
