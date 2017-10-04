# Horizon

> ## This repository has moved to [the go monorepo: https://github.com/stellar/go/tree/master/services/horizon](https://github.com/stellar/go/tree/master/services/horizon). Please direct any future Pull Requests there.

[![Build Status](https://travis-ci.org/stellar/horizon.svg?branch=master)](https://travis-ci.org/stellar/horizon)

Horizon is the [client facing API](/docs) server for the Stellar ecosystem.  It acts as the interface between stellar-core and applications that want to access the Stellar network. It allows you to submit transactions to the network, check the status of accounts, subscribe to event streams, etc. See [an overview of the Stellar ecosystem](https://www.stellar.org/developers/guides/get-started/) for more details.

## Downloading the server
[Prebuilt binaries](https://github.com/stellar/horizon/releases) of horizon are available on the 
[releases page](https://github.com/stellar/horizon/releases).

| Platform       | Binary file name                                                                         |
|----------------|------------------------------------------------------------------------------------------|
| Mac OSX 64 bit | [horizon-darwin-amd64](https://github.com/stellar/horizon/releases/download/v0.11.0/horizon-v0.11.0-darwin-amd64.tar.gz)      |
| Linux 64 bit   | [horizon-linux-amd64](https://github.com/stellar/horizon/releases/download/v0.11.0/horizon-v0.11.0-linux-amd64.tar.gz)       |
| Windows 64 bit | [horizon-windows-amd64.exe](https://github.com/stellar/horizon/releases/download/v0.11.0/horizon-v0.11.0-windows-amd64.zip) |

Alternatively, you can [build](#building) the binary yourself.

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

## Contributing
Please see the [CONTRIBUTING.md](./CONTRIBUTING.md) for details on how to contribute to this project.
