# Changelog

All notable changes to this project will be documented in this
file.  This project adheres to [Semantic Versioning](http://semver.org/).

As this project is pre 1.0, breaking changes may happen for minor version
bumps.  A breaking change will get clearly notified in this log.


## [Unreleased]

### Bug fixes

- Trade resources now include "bought_amount" and "sold_amount" fields when being viewed through the "Orderbook Trades" endpoint.
- Fixes #322: orderbook summaries with over 20 bids now return the correct price levels, starting with the closest to the spread.

## [v0.7.0] - 2016-01-10

### Added

- The account resource now includes links to the account's trades and data values.

### Bug fixes

- Fixes paging_token attribute of account resource
- Fixes race conditions in friendbot
- Fixes #202: Add price and price_r to "manage_offer" operation resources
- Fixes #318: order books for the native currency now filters correctly.

## [v0.6.2] - 2016-08-18

### Bug fixes

- Fixes streaming (SSE) requests, which were broken in v0.6.0

## [v0.6.1] - 2016-07-26

### Bug fixes

- Fixed an issue where accounts were not being properly returned when the  history database had no record of the account.


## [v0.6.0] - 2016-07-20

This release contains the initial implementation of the "Abridged History System".  It allows a horizon system to be operated without complete knowledge of the ledger's history.  With this release, horizon will start ingesting data from the earliest point known to the connected stellar-core instance, rather than ledger 1 as it behaved previously.  See the admin guide section titled "Ingesting stellar-core data" for more details.

### Added

- *Elder* ledgers have been introduced:  An elder ledger is the oldest ledger known to a db.  For example, the `core_elder_ledger` attribute on the root endpoint refers to the oldest known ledger stored in the connected stellar-core database.
- Added the `history-retention-count` command line flag, used to specify the amount of historical data to keep in the history db.  This is expressed as a number of ledgers, for example a value of `362880` would retain roughly 6 weeks of data given an average of 10 seconds per ledger.
- Added the `history-stale-threshold` command line flag to enable stale history protection.  See the admin guide for more info.
- Horizon now reports the last ledger ingested to stellar-core using the `setcursor` command.
- Requests for data that precede the recorded window of history stored by horizon will receive a `410 Gone` http response to allow software to differentiate from other "not found" situations.
- The new `db reap` command will manually trigger the deletion of unretained historical data
- A background process on the server now deletes unretained historical once per hour.

### Changed

- BREAKING: When making a streaming request, a normal error response will be returned if an error occurs prior to sending the first event.  Additionally, the initial http response and streaming preamble will not be sent until the first event is available.
- BREAKING: `horizon_latest_ledger` has renamed to `history_latest_ledger`
- Horizon no longer needs to begin the ingestion of historical data from ledger sequence 1.  
- Rows in the `history_accounts` table are no longer identified using the "Total Order ID" that other historical records  use, but are rather using a simple auto-incremented id.

### Removed

- The `/accounts` endpoint, which lets a consumer page through the entire set of accounts in the ledger, has been removed.  The change from complete to an abridged history in horizon makes the endpoint mostly useless, and after consulting with the community we have decided to remove the endpoint.

## [v0.5.1] - 2016-04-28

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

[Unreleased]: https://github.com/stellar/horizon/compare/v0.7.0...master
[v0.7.0]: https://github.com/stellar/horizon/compare/v0.6.2...v0.7.0
[v0.6.2]: https://github.com/stellar/horizon/compare/v0.6.1...v0.6.2
[v0.6.1]: https://github.com/stellar/horizon/compare/v0.6.0...v0.6.1
[v0.6.0]: https://github.com/stellar/horizon/compare/v0.5.1...v0.6.0
[v0.5.1]: https://github.com/stellar/horizon/compare/v0.5.0...v0.5.1
[v0.5.0]: https://github.com/stellar/horizon/compare/v0.4.0...v0.5.0
[v0.4.0]: https://github.com/stellar/horizon/compare/v0.3.0...v0.4.0
[v0.3.0]: https://github.com/stellar/horizon/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/stellar/horizon/compare/v0.1.1...v0.2.0
[v0.1.1]: https://github.com/stellar/horizon/compare/v0.1.0...v0.1.1
