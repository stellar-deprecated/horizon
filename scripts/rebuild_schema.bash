#! /usr/bin/env bash
set -e

# This scripts rebuilds the latest.sql file included in the schema package.

gb generate github.com/stellar/horizon/db2/schema
gb build
dropdb horizon_schema --if-exists
createdb horizon_schema
DATABASE_URL=postgres://localhost/horizon_schema?sslmode=disable ./bin/horizon db migrate up

DUMP_OPTS="--schema=public --no-owner --no-acl --inserts"
LATEST_PATH="src/github.com/stellar/horizon/db2/schema/latest.sql"
BLANK_PATH="src/github.com/stellar/horizon/test/scenarios/blank-horizon.sql"

pg_dump postgres://localhost/horizon_schema?sslmode=disable $DUMP_OPTS \
  | sed '/SET idle_in_transaction_session_timeout/d'  \
  | sed '/SET row_security/d' \
  > $LATEST_PATH
pg_dump postgres://localhost/horizon_schema?sslmode=disable \
  --clean --if-exists $DUMP_OPTS \
  | sed '/SET idle_in_transaction_session_timeout/d'  \
  | sed '/SET row_security/d' \
  > $BLANK_PATH

gb generate github.com/stellar/horizon/db2/schema
gb generate github.com/stellar/horizon/test
gb build
