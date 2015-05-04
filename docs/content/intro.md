+++
date = "2015-05-04T08:00:59-07:00"
draft = false
title = "Introduction"
weight = 0
+++

*NOTE: Horizon is in very active development*

Horizon is the client facing API server for the Stellar ecosystem.  See [an overview of the Stellar ecosystem](TODO) for more details.

Horizon provides (well, intends to provide when complete) two significant portions of functionality:  The Transactions API and the History API.

## Transactions API

The Transactions API exists to help you make transactions against the Stellar network.  It provides ways to help you create valid transactions, such as providing an account's sequence number or latest known balances. 

In addition to the read endpoints, the Transactions API also provides the endpoint to submit transactions.

### Future additions

The current capabilities of the Transactions API does not represent what will be available at the official launch of the new Stellar network.  Notable additions to come:

- Endpoints to read the current state of a given order book or books to aid in creating offer transactions
- Endpoints to calculate suitable paths for a payments

## History API

The History API provides endpoints for retrieving data about what has happened in the past on the Stellar network.  It provides (or will provide) endpoints that let you:

- Retrieve transaction details
- Load transactions that effect a given account
- Load payment history for an account
- Load trade history for a given order book


### Future additions

The history API is pretty sparse at present.  Presently you can page through all transactions in application order, or page through transactions that a apply to a single account.  This is really only useful for explaining how paging and filtering works within Horizon, as most useful information for transactions are related to their operations.

## API Overview

The following section describes a couple of important concepts for the Horizon API at a high level.  Understanding these concepts will help make your overall experience integrating with Horizon much easier.

### Response Format

Rather than using a fully custom way of representing the resources we expose in Horizon, we use [HAL](http://stateless.co/hal_specification.html). HAL is a hypermedia format in JSON that remains simple while giving us a couple of benefits such as simpler client integration for several languages. See [this wiki page](https://github.com/mikekelly/hal_specification/wiki/Libraries) for a list of libraries.

See [Responses](responses.md) for more details

### Error Format

HAL doesn't really have any special consideration for error responses.  To provide some standardization to our API's error messages we use the [Problem Details for HTTP APIs RFC](https://tools.ietf.org/html/draft-ietf-appsawg-http-problem-00)

See [errors](errors.md) for more details

### Paging

Some resources in Horizon represent a collection of other resources.  Almost always, loading this collection in its entirety is not feasible.  To work around this, we provide a way to page through a collection.  

The paging system in Horizon is known as a _token-based_ paging system.  There is no "page 3" or the like.  Paging through a collection in a token-based paging system involves three pieces of data:

- the *paging token*, which is an opaque value that logically represents the last record seen by a client.
- the *limit*, or page size, a positive integer.
- the *order* applied to the whole collection

See [paging](paging.md) for more details.

## API Reference

While Horizon is lightly self-documenting through use of hyperlinks in responses (such that you should be able to navigate through the dataset without too much trouble), we also have reference documentation available.

We document our API using [API Blueprint](https://apiblueprint.org/), and you can see the raw file [here](horizon.apib).

We host the documentation for our API presently with apiary.  You can find this documentation at (http://docs.stellarhorizon.apiary.io/)


