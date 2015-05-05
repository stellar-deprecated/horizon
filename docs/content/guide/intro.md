+++
date = "2015-05-04T08:00:59-07:00"
draft = false
title = "Introduction"
weight = -1
+++

Horizon is the client facing API server for the Stellar ecosystem.  See [an overview of the Stellar ecosystem](TODO) for more details.

Horizon provides three significant portions of functionality:  The Transactions API, the History API, and the Trading API.

## Transactions API

The Transactions API exists to help you make transactions against the Stellar network.  It provides ways to help you create valid transactions, such as providing an account's sequence number or latest known balances. 

In addition to the read endpoints, the Transactions API also provides the endpoint to submit transactions.

## History API

The History API provides endpoints for retrieving data about what has happened in the past on the Stellar network.  It provides (or will provide) endpoints that let you:

- Retrieve transaction details
- Load transactions that effect a given account
- Load payment history for an account
- Load trade history for a given order book


## Trading API



