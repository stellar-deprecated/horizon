---
id: follow_received_payments
title: Follow Received Payments
category: Tutorials
---

This tutorial shows how easy it is to watch for incoming payments on an [account][concept_account]
using JavaScript and `EventSource`.  We will eschew using `js-stellar-sdk`, the
high-level helper library, to show that it is possible for you to perform this
task on your own, with whatever programming language you would like to use.

This tutorial assumes that you:

- Have node.js installed locally on your machine.
- Have curl installed locally on your machine.
- Are running on Linux, OS X, or any other system that has access to a bash-like
  shell.
- Are familiar with launching and running commands in a terminal.

In this tutorial we will learn:

- How to create a new account.
- How to fund your account using friendbot
- How to follow payments to your account using EventSource and Server-Sent Events.

## Project Skeleton

Let's get started by building our project skeleton:

```bash
$ mkdir follow_tutorial
$ cd follow_tutorial
$ npm install --save stellar-base
$ npm install --save eventsource
```

This should have created a `package.json` in the `follow_tutorial` directory.
You can check that everything went well by running the following command:

```bash
$ node -e "require('stellar-base')"
```

Everything was successful if no output it generated from the above command.  Now
let's write a script to create a new account.

## Creating an account

Create a new file named `make_account.js` and paste the following text into it:

```javascript
var Keypair = require("stellar-base").Keypair;

var newAccount = Keypair.random();

console.log("New account created!");
console.log("  Address: " + newAccount.address());
console.log("  Seed: " + newAccount.seed());
```

Save the file and run it:

```bash
$ node make_account.js
New account created!
  Address: GB7JFK56QXQ4DVJRNPDBXABNG3IVKIXWWJJRJICHRU22Z5R5PI65GAK3
  Seed: SCU36VV2OYTUMDSSU4EIVX4UUHY3XC7N44VL4IJ26IOG6HVNC7DY5UJO
$
```

Before our account can do anything it must be funded.  Indeed, before an account
is funded it does not truly exist!

## Funding your account

The Stellar test network provides the Friendbot, a tool that developers
can use to get testnet lumens for testing purposes. To fund your account, simply
execute the following curl command:

```bash
$ curl https://horizon-testnet.stellar.org/friendbot?addr=GB7JFK56QXQ4DVJRNPDBXABNG3IVKIXWWJJRJICHRU22Z5R5PI65GAK3
```

Don't forget to replace the address above with your own.  If the request
succeeds, you should see a response like:

```json
{
  "hash": "ed9e96e136915103f5d8978cbb2036628e811f2c59c4c3d88534444cf504e360",
  "result": "received",
  "submission_result": "000000000000000a0000000000000001000000000000000000000000"
}
```

After a few seconds, the Stellar network will perform consensus, close the
ledger, and your account will have been created.  Next up we will write a script
that watches for new payments to your account and outputs a message to the
terminal.

## Following payments

TODO

## Testing it out

TODO

[concept_account]: https://github.com/stellar/docs/tree/master/docs/accounts.md
