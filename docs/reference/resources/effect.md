---
id: effect
title: Effect
category: Resources
---

A successful operation will yield zero or more **effects**.  These effects
represent specific changes that occur in the ledger, but are not necessarily
directly reflected in the [ledger][concept_ledger] or [history][concept_history], as [transactions][concept_transactions] and [operations][concept_operations] are.

## Effect types

We can distinguish 4 effect groups:
- Account effects
- Signer effects
- Trustline effects
- Trading effects

### Account effects

| Type                        | Operation                                             |
| Account Created             | create_account                                        |
| Account Removed             | merge_account                                         |
| Account Credited            | create_account, payment, path_payment, merge_account  |
| Account Debited             | create_account, payment, path_payment, create_account |
| Account Thresholds Updated  | set_options                                           |
| Account Home Domain Updated | set_options                                           |
| Account Flags Updated       | set_options                                           |

### Signer effects

| Type           | Operation   |
| Signer Created | set_options |
| Signer Removed | set_options |
| Signer Updated | set_options |

### Trustline effects

| Type                   | Operation                 |
| Trustline Created      | change_trust              |
| Trustline Removed      | change_trust              |
| Trustline Updated      | change_trust, allow_trust |
| Trustline Authorized   | allow_trust               |
| Trustline Deauthorized | allow_trust               |

### Trading effects

| Type          | Operation                                        |
| Offer Created | manage_offer, create_passive_offer               |
| Offer Removed | manage_offer, create_passive_offer, path_payment |
| Offer Updated | manage_offer, create_passive_offer, path_payment |
| Trade         | manage_offer, create_passive_offer, path_payment |


## Attributes

| Attribute | Type |     |
| --------- | ---- | --- |
|           |      |     |

## Links

| rel | Example | Relation |
| --- | ------- | -------- |
|     |         |          |

## Example

```json
//TODO
```

## Endpoints

| Resource | Type | Resource URL |
| -------- | ---- | ------------ |
|          |      |              |

[concept_ledger][https://github.com/stellar/docs/tree/master/docs/ledger.md]
[concept_history][https://github.com/stellar/docs/tree/master/docs/history.md]
[concept_transactions]: https://github.com/stellar/docs/tree/master/docs/transaction.md
[concept_operations]: https://github.com/stellar/docs/tree/master/docs/operations.md
