#! /usr/bin/env bash

set -e

PACKAGES=$(find src/github.com/stellar/go-horizon -type d | sed -e 's/^src\///')

for i in $PACKAGES; do
    gb test $i
done

echo "All tests pass!"
