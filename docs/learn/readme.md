---
title: Overview
---

Horizon is an API server for the Stellar ecosystem.  It acts as the interface between [stellar-core](https://github.com/stellar/stellar-core) and applications that want to access the Stellar network. It allows you to submit transactions to the network, check the status of accounts, subscribe to event streams, etc. See [an overview of the Stellar ecosystem](https://www.stellar.org/developers/learn/) for details of where Horizon fits in. You can also watch a [talk on Horizon](https://www.youtube.com/watch?v=AtJ-f6Ih4A4) by Stellar.org developer Scott Fleckenstein:

[![Horizon: API webserver for the Stellar network](https://41.media.tumblr.com/44d949a8dae988fb7126877a19bb3ed7/tumblr_o1ztsgaJ5Y1upjcg7o1_540.png "Horizon: API webserver for the Stellar network")](https://www.youtube.com/watch?v=AtJ-f6Ih4A4)

Horizon provides a RESTful API to allow client applications to interact with the Stellar network. You can communicate with Horizon using cURL or just your web browser. However, if you're building a client application, you'll likely want to use a Stellar SDK in the language of your client.
SDF provides a [JavaScript SDK](https://www.stellar.org/developers/js-stellar-sdk/learn/index.html) for clients to use to interact with Horizon.

SDF runs a instance of Horizon that is connected to the test net: [https://horizon-testnet.stellar.org/](https://horizon-testnet.stellar.org/) and one that is connected to the public Stellar network:
[https://horizon.stellar.org/](https://horizon.stellar.org/).

Libraries (in various states of completeness) for interacting with Horizon in other languages:<br>
- [JavaScript](https://www.stellar.org/developers/learn/js-stellar)
- [Ruby](https://github.com/stellar/ruby-stellar-sdk) *Community maintained*
- [Go](https://github.com/stellar/go-stellar-base) *Community maintained*
- [Python](https://github.com/StellarCN/py-stellar-base) *Community maintained*
- [Java](https://github.com/stellar/java-stellar-base) *Community maintained*
- [C#](https://github.com/QuantozTechnology/csharp-stellar-base) *Community maintained*
