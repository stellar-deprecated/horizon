#! /usr/bin/env bash
set -e

PACKAGES=$(find src/github.com/stellar/horizon/test/scenarios -iname '*.rb')

for i in $PACKAGES; do
  bundle exec scc -r $i --dump-root-db > "${i%.rb}-core.sql"
done
