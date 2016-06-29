#! /usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PACKAGES=$(find src/github.com/stellar/horizon/test/scenarios -iname '*.rb' -not -name '_common_accounts.rb')
# PACKAGES=$(find src/github.com/stellar/horizon/test/scenarios -iname 'kahuna.rb' -not -name '_common_accounts.rb')

gb build

dropdb hayashi_scenarios --if-exists
createdb hayashi_scenarios

export STELLAR_CORE_DATABASE_URL="postgres://localhost/hayashi_scenarios?sslmode=disable"
export STELLAR_CORE_URL="http://localhost:8080"
export DATABASE_URL="postgres://localhost/horizon_scenarios?sslmode=disable"
export NETWORK_PASSPHRASE="Test SDF Network ; September 2015"

# run all scenarios
for i in $PACKAGES; do
  CORE_SQL="${i%.rb}-core.sql"
  HORIZON_SQL="${i%.rb}-horizon.sql"
  bundle exec scc -r $i --dump-root-db > $CORE_SQL

  # load the core scenario
  psql $STELLAR_CORE_DATABASE_URL < $CORE_SQL

  # recreate horizon dbs
  dropdb horizon_scenarios --if-exists
  createdb horizon_scenarios


  # import the core data into horizon
  $DIR/../bin/horizon db init
  $DIR/../bin/horizon db reingest

  # write horizon data to sql file
  pg_dump $DATABASE_URL --clean --if-exists --no-owner --no-acl --inserts > $HORIZON_SQL
done


# commit new sql files to bindata
gb generate github.com/stellar/horizon/test/scenarios
# gb test github.com/stellar/horizon/ingest
