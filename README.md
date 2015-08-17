# Note this code is pre-alpha.
It is definitely not ready yet for production.

# Horizon
[![Build Status](https://travis-ci.org/stellar/go-horizon.svg?branch=master)](https://travis-ci.org/stellar/go-horizon)
[![docs examples](https://sourcegraph.com/api/repos/github.com/stellar/go-horizon/.badges/docs-examples.svg)](https://sourcegraph.com/github.com/stellar/go-horizon)

Horizon is the [client facing API](http://docs.stellarhorizon.apiary.io) server
for the Stellar ecosystem.  See [an overview of the Stellar
ecosystem](https://www.stellar.org/galaxy/getting-started/) for more details.


## Building

[gb](getgb.io) is used for building horizon.

Given you have a running golang installation, you can install this with:

```bash
go get -u github.com/constabulary/gb/...
```

From within the project directory, simply run `gb build`.  After successful
completion, you should find `bin/horizon` is present in the project directory.

## Regenerating generated code

Horizon uses two go tools you'll need to install:
1. [go-bindata](https://github.com/jteeuwen/go-bindata) is used to bundle test data
1. [go-codegen](https://github.com/nullstyle/go-codegen) is used to generate some boilerplate code

After the above are installed, simply run `gb generate`.

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
