---
title: Administration
---

Horizon is responsible for providing an HTTP API to data in the Stellar network. It ingests and re-serves the data produced by the stellar network in a form that is easier to consume than the performance-oriented data representations used by stellar-core.

## Why run horizon?

The stellar development foundation runs two horizon servers, one for the public network and one for the test network, free for anyone's use at https://horizon.stellar.org and https://horizon-testnet.stellar.org.  These servers should be fine for development and small scale projects, but is not recommended that you use them for production services that need strong reliability.  By running horizon within your own infrastructure provides a number of benefits:

  - Multiple instances can be run for redundancy and scalability.
  - Request rate limiting can be disabled.
  - Full operational control without dependency on the Stellar Development Foundations operations.

## Prerequisites

Horizon is a dependent upon a stellar-core server.  Horizon needs access to both the SQL database and the HTTP API that is published by stellar-core. See [the administration guide](https://www.stellar.org/developers/stellar-core/learn/admin.html
) to learn how to set up and administer a stellar-core server.  Secondly, horizon is dependent upon a postgresql server, which it uses to store processed core data for ease of use. Horizon requires postgres version >= 9.3.

In addition to the two required prerequisites above, you may optionally install a redis server to be used for rate limiting requests.

## Installing

To install horizon, you have a choice: either downloading a [prebuilt release for your target architecture](https://github.com/stellar/horizon/releases/download/v0.11.0/horizon-v0.11.0-linux-amd64.tar.gz) and operation system, or [building horizon yourself](#Building).  When either approach is complete, you will find yourself with a directory containing a file named `horizon`.  This file is a native binary.

After building or unpacking horizon, you simply need to copy the native binary into a directory that is part of your PATH.  Most unix-like systems have `/usr/local/bin` in PATH by default, so unless you have a preference or know better, we recommend you copy the binary there.

To test the installation, simply run `horizon --help` from a terminal.  If the help for horizon is displayed, your installation was successful. Note: some shells, such as zsh, cache PATH lookups.  You may need to clear your cache  (by using `rehash` in zsh, for example) before trying to run `horizon --help`.


## Building

Should you decide not to use one of our prebuilt releases, you may instead build horizon from source.  To do so, you need to install some developer tools:

- A unix-like operating system with the common core commands (cp, tar, mkdir, bash, etc.)
- A compatible distribution of go (we officially support go 1.6 and later)
- [gb](https://getgb.io/)
- [git](https://git-scm.com/)

Provided your workstation satisfies the requirements above, follow the steps below:

1. Clone horizon's source:  `git clone https://github.com/stellar/horizon.git && cd horizon`
2. Download external dependencies: `gb vendor restore`
3. Build the binary: `gb build`

After running the above commands have succeeded, the built horizon will have be written into the `bin` subdirectory of the current directory.

Note:  Building directly on windows is not supported.


## Configuring

Horizon is configured using command line flags or environment variables.  To see the list of command line flags that are available (and their default values) for your version of horizon, run:

`horizon --help`

As you will see if you run the command above, horizon defines a large number of flags, however only three are required:

| flag                    | envvar                      | example                              |
|-------------------------|-----------------------------|--------------------------------------|
| `--db-url`              | `DATABASE_URL`              | postgres://localhost/horizon_testnet |
| `--stellar-core-db-url` | `STELLAR_CORE_DATABASE_URL` | postgres://localhost/core_testnet    |
| `--stellar-core-url`    | `STELLAR_CORE_URL`          | http://localhost:11626               |

`--db-url` specifies the horizon database, and its value should be a valid [PostgreSQL Connection URI](http://www.postgresql.org/docs/9.2/static/libpq-connect.html#AEN38419).  `--stellar-core-db-url` specifies a stellar-core database which will be used to load data about the stellar ledger.  Finally, `--stellar-core-url` specifies the HTTP control port for an instance of stellar-core.  This URL should be associated with the stellar-core that is writing to the database at `--stellar-core-db-url`.

Specifying command line flags every time you invoke horizon can be cumbersome, and so we recommend using environment variables.  There are many tools you can use to manage environment variables:  we recommend either [direnv](http://direnv.net/) or [dotenv](https://github.com/bkeepers/dotenv).  A template configuration that is compatible with dotenv can be found in the [horizon git repo](https://github.com/stellar/horizon/blob/master/.env.template).



## Preparing the database

Before the horizon server can be run, we must first prepare the horizon database.  This database will be used for all of the information produced by horizon, notably historical information about successful transactions that have occurred on the stellar network.  

To prepare a database for horizon's use, first you must ensure the database is blank.  It's easiest to simply create a new database on your postgres server specifically for horizon's use.  Next you must install the schema by running `horizon db init`.  Remember to use the appropriate command line flags or environment variables to configure horizon as explained in [Configuring ](#Configuring).  This command will log any errors that occur.

## Running

Once your horizon database is configured, you're ready to run horizon.  To run horizon you simply run `horizon` or `horizon serve`, both of which start the HTTP server and start logging to standard out.  When run, you should see some output that similar to:

```
INFO[0000] Starting horizon on :8000                     pid=29013
```

The log line above announces that horizon is ready to serve client requests. Note: the numbers shown above may be different for your installation.  Next we can confirm that horizon is responding correctly by loading the root resource.  In the example above, that URL would be [http://127.0.0.1:8000/] and simply running `curl http://127.0.0.1:8000/` shows you that the root resource can be loaded correctly.


## Ingesting stellar-core data

Horizon provides most of its utility through ingested data.  Your horizon server can be configured to listen for and ingest transaction results from the connected stellar-core.  We recommend that within your infrastructure you run one (and only one) horizon process that is configured in this way.   While running multiple ingestion processes will not corrupt the horizon database, your error logs will quickly fill up as the two instances race to ingest the data from stellar-core.  We may develop a system that coordinates multiple horizon processes in the future, but we would also be happy to include an external contribution that accomplishes this.

To enable ingestion, you must either pass `--ingest=true` on the command line or set the `INGEST` environment variable to "true".

### Managing storage for historical data

Given an empty horizon database, any and all available history on the attached stellar-core instance will be ingested. Over time, this recorded history will grow unbounded, increasing storage used by the database.  To keep you costs down, you may configure horizon to only retain a certain number of ledgers in the historical database.  This is done using the `--history-retention-count` flag or the `HISTORY_RETENTION_COUNT` environment variable.  Set the value to the number of recent ledgers you with to keep around, and every hour the horizon subsystem will reap expired data.  Alternatively, you may execute the command `horizon db reap` to force a collection.

### Surviving stellar-core downtime

Horizon tries to maintain a gap-free window into the history of the stellar-network.  This reduces the number of edge cases that horizon-dependent software must deal with, aiming to make the integration process simpler.  To maintain a gap-free history, horizon needs access to all of the metadata produced by stellar-core in the process of closing a ledger, and there are instances when this metadata can be lost.  Usually, this loss of metadata occurs because the stellar-core node went offline and performed a catchup operation when restarted.

To ensure that the metadata required by horizon is maintained, you have several options: You may either set the `CATCHUP_COMPLETE` stellar-core configuration option to `true` or configure `CATCHUP_RECENT` to determine the amount of time your stellar-core can be offline without having to rebuild your horizon database.

We _do not_ recommend using the `CATCHUP_COMPLETE` method, as this will force stellar-core to apply every transaction from the beginning of the ledger, which will take an ever increasing amount of time.  Instead, we recommend you set the `CATCHUP_RECENT` config value.  To do this, determine how long of a downtime you would like to survive (expressed in seconds) and divide by ten.  This roughly equates to the number of ledgers that occur within you desired grace period (ledgers roughly close at a rate of one every ten seconds).  With this value set, stellar-core will replay transactions for ledgers that are recent enough, ensuring that the metadata needed by horizon is present.

### Correcting gaps in historical data

In the section above, we mentioned that horizon _tries_ to maintain a gap-free window.  Unfortunately, it cannot directly control the state of stellar-core and so gaps may form due to extended down time.  When a gap is encountered, horizon will stop ingesting historical data and complain loudly in the log with error messages (log lines will include "ledger gap detected").  To resolve this situation, you must re-establish the expected state of the stellar-core database and purge historical data from horizon's database.  We leave the details of this process up to the reader as it is dependent upon your operating needs and configuration, but we offer one potential solution:

We recommend you configure the HISTORY_RETENTION_COUNT in horizon to a value less than or equal to the configured value for CATCHUP_RECENT in stellar-core.  Given this situation any downtime that would cause a ledger gap will require a downtime greater than the amount of historical data retained by horizon.  To re-establish continuity, simply:

1.  Stop horizon.
2.  run `horizon db reap` to clear the historical database.
3.  Clear the cursor for horizon by running `stellar-core -c "dropcursor?id=HORIZON"` (ensure capitilization is maintained).
4.  Clear ledger metadata from before the gap by running `stellar-core -c "maintenance?queue=true"`.
5.  Restart horizon.    

## Managing Stale Historical Data

Horizon ingests ledger data from a connected instance of stellar-core.  In the event that stellar-core stops running (or if horizon stops ingesting data for any other reason), the view provided by horizon will start to lag behind reality.  For simpler applications, this may be fine, but in many cases this lag is unacceptable and the application should not continue operating until the lag is resolved.

To help applications that cannot tolerate lag, horizon provides a configurable "staleness" threshold.  Given that enough lag has accumulated to surpass this threshold (expressed in number of ledgers), horizon will only respond with an error: [`stale_history`](./errors/stale-history.md).  To configure this option, use either the `--history-stale-threshold` command line flag or the `HISTORY_STALE_THRESHOLD` environment variable.  NOTE:  non-historical requests (such as submitting transactions or finding payment paths) will not error out when the staleness threshold is surpassed.

## Monitoring

To ensure that your instance of horizon is performing correctly we encourage you to monitor it, and provide both logs and metrics to do so.  

Horizon will output logs to standard out.  Information about what requests are coming in will be reported, but more importantly and warnings or errors will also be emitted by default.  A correctly running horizon instance will not ouput any warning or error log entries.

Metrics are collected while a horizon process is running and they are exposed at the `/metrics` path.  You can see an example at (https://horizon-testnet.stellar.org/metrics).

## I'm Stuck! Help!

If any of the above steps don't work or you are otherwise prevented from correctly setting up horizon, please come to our community and tell us.  Either [post an issue in the horizon github repo](https://github.com/stellar/horizon/issues) or [chat with us on slack](http://slack.stellar.org/) to ask for help.
