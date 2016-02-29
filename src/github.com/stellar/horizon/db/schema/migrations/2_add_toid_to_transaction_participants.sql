-- +migrate Up
ALTER TABLE history_transaction_participants
  ADD history_transaction_id bigint
;

-- +migrate Down
ALTER TABLE history_transaction_participants
  DROP history_transaction_id
;
