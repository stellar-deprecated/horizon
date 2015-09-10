#! /usr/bin/env bash

set -e

PACKAGES=$(find src/github.com/stellar/horizon -type d | sed -e 's/^src\///')

for i in $PACKAGES; do
	has_tests=`ls -1 src/$i/*_test.go 2>/dev/null | wc -l`

	if [ $has_tests != 0 ]; then
		$GOPATH/bin/gb test $i
	else 
		echo "skipping $i, no tests"
	fi
done

echo "All tests pass!"
