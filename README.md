# Horizon
[![Build Status](https://travis-ci.org/stellar/horizon.svg?branch=master)](https://travis-ci.org/stellar/horizon)

Horizon is the [client facing API](/docs) server for the Stellar ecosystem.  It acts as the interface between stellar-core and applications that want to access the Stellar network. It allows you to submit transactions to the network, check the status of accounts, subscribe to event streams, etc. See [an overview of the Stellar ecosystem](https://www.stellar.org/developers/learn/) for more details.

## Dependencies

Horizon requires go 1.6 or higher to build. See (https://golang.org/doc/install) for installation instructions.

## Building

[gb](http://getgb.io) is used for building horizon.

Given you have a running golang installation, you can install this with:

```bash
go get -u github.com/constabulary/gb/...
```

Next, you must download the source for packages that horizon depends upon.  From within the project directory, run:

```bash
gb vendor restore
```

Then, simply run `gb build`.  After successful
completion, you should find `bin/horizon` is present in the project directory.

More detailed intructions and [admin guide](/docs/reference/admin.md). 

## Developing Horizon

See [the development guide](docs/developing.md).
