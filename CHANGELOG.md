# Changelog

All notable changes to this project will be documented in this
file.  This project adheres to [Semantic Versioning](http://semver.org/).

As this project is pre 1.0, breaking changes may happen for minor version
bumps.  A breaking change will get clearly notified in this log.

## [Unreleased]

### Added

  - ManageData operation data is now rendered in the various operation end points.

### Bug fixes

- Transaction memos that contain utf-8 are now properly rendered in browsers by properly setting the charset of the http response.

## [v0.5.0] - 2016-04-22

### Added

- BREAKING: Horizon can now import data from stellar-core without the aid of the horizon-importer project.  This process is now known as "ingestion", and is enabled by either setting the `INGEST` environment variable to "true" or specifying "--ingest" on the launch arguments for the horizon process.  Only one process should be running in this mode for any given horizon database.
- Add `horizon db init`, used to install the latest bundled schema for the horizon database.
- Add `horizon db reingest` command, used to update outdated or corrupt horizon database information.  Admins may now use `horizon db reingest outdated` to migrate any old data when updated horizon.
- Added `network_passphrase` field to root resource.
- Added `fee_meta_xdr` field to transaction resource.

### Bug fixes
- Corrected casing on the "offers" link of an account resource.

## [v0.4.0] - 2016-02-19

### Added

- Add `horizon db migrate [up|down|redo]` commands, used for installing schema migrations.  This work is in service of porting the horizon-importer project directly to horizon.
- Add support for TLS: specify `--tls-cert` and `--tls-key` to enable.
- Add support for HTTP/2.  To enable, use TLS.

### Removed

- BREAKING CHANGE: Removed support for building on go versions lower than 1.6

## [v0.3.0] - 2016-01-29

### Changes

- Fixed incorrect `source_amount` attribute on pathfinding responses.
- BREAKING CHANGE: Sequence numbers are now encoded as strings in JSON responses.
- Fixed broken link in the successful response to a posted transaction

## [v0.2.0] - 2015-12-01
### Changes

- BREAKING CHANGE: the `address` field of a signer in the account resource has been renamed to `public_key`.
- BREAKING CHANGE: the `address` on the account resource has been renamed to `account_id`.

## [v0.1.1] - 2015-12-01

### Added
- Github releases are created from tagged travis builds automatically

[Unreleased]: https://github.com/stellar/horizon/compare/v0.5.0...master
[v0.5.0]: https://github.com/stellar/horizon/compare/v0.4.0...v0.5.0
[v0.4.0]: https://github.com/stellar/horizon/compare/v0.3.0...v0.4.0
[v0.3.0]: https://github.com/stellar/horizon/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/stellar/horizon/compare/v0.1.1...v0.2.0
[v0.1.1]: https://github.com/stellar/horizon/compare/v0.1.0...v0.1.1
