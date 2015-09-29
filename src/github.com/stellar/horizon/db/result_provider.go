package db

import (
	"database/sql"
	"github.com/stellar/horizon/txsub"
	"golang.org/x/net/context"
)

type ResultProvider struct {
	Core    *sql.DB
	History *sql.DB
}

func (rp *ResultProvider) ResultByHash(ctx context.Context, hash string) txsub.Result {

	// query history database
	var hr TransactionRecord
	hq := TransactionByHashQuery{
		SqlQuery: SqlQuery{rp.History},
		Hash:     hash,
	}

	err := Get(ctx, hq, &hr)
	if err == nil {
		return txResultFromHistory(hr)
	}

	if err != ErrNoResults {
		return txsub.Result{Err: err}
	}

	// query core database
	var cr CoreTransactionRecord
	cq := CoreTransactionByHashQuery{
		SqlQuery: SqlQuery{rp.Core},
		Hash:     hash,
	}

	err = Get(ctx, cq, &cr)
	if err == nil {
		return txResultFromCore(cr)
	}

	if err != ErrNoResults {
		return txsub.Result{Err: err}
	}

	// if no result was found in either db, return ErrNoResults
	return txsub.Result{Err: txsub.ErrNoResults}
}

func txResultFromHistory(tx TransactionRecord) txsub.Result {
	return txsub.Result{
		Hash:           tx.TransactionHash,
		LedgerSequence: tx.LedgerSequence,
		EnvelopeXDR:    tx.TxEnvelope.String,
		ResultXDR:      tx.TxResult.String,
		ResultMetaXDR:  tx.TxMeta.String,
	}
}

func txResultFromCore(tx CoreTransactionRecord) txsub.Result {
	return txsub.Result{
		Hash:           tx.TransactionHash,
		LedgerSequence: tx.LedgerSequence,
		EnvelopeXDR:    tx.EnvelopeXDR,
		ResultXDR:      tx.ResultXDR,
		ResultMetaXDR:  tx.ResultMetaXDR,
	}
}
