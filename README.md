# Note this code is pre-alpha.
It is definitely not ready yet for production.

# Horizon
[![Build Status](https://travis-ci.org/stellar/go-horizon.svg?branch=master)](https://travis-ci.org/stellar/go-horizon)
[![docs examples](https://sourcegraph.com/api/repos/github.com/stellar/go-horizon/.badges/docs-examples.svg)](https://sourcegraph.com/github.com/stellar/go-horizon)

Horizon is the [client facing API](http://docs.stellarhorizon.apiary.io) server
for the Stellar ecosystem.  See [an overview of the Stellar
ecosystem](https://www.stellar.org/galaxy/getting-started/) for more details.

## Installing Dependencies

Horizon uses [gb](getgb.io) to manage go dependencies, which are bundled into
the `vendor` directory.

## Building

From within the project directory, simply run `gb build`.  After successful
completion, you should find `bin/horizon` is present in the project directory.

## Regenerating generated code

Files ending in `_generated.go` are generating using
[go-codegen](https://github.com/nullstyle/go-codegen).  Before you can
regenerate the code, you'll need to install that tool.  After installed, simply
run `go generate`.

## Running Tests

first, create two local Postgres databases, and start a redis server on port
`6379`

```bash
psql -c 'create database "horizon_test";'
psql -c 'create database "stellar-core_test";'
redis-server
```

then, run the tests like so:

```bash
bash script/run_tests.bash
```
