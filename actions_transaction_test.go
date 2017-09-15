package horizon

import (
	"encoding/json"
	"net/url"
	"testing"

	"github.com/stellar/horizon/resource"
	"github.com/stellar/horizon/txsub"
	"github.com/stellar/horizon/txsub/sequence"
)

func TestTransactionActions_Show(t *testing.T) {
	ht := StartHTTPTest(t, "base")
	defer ht.Finish()

	w := ht.Get("/transactions/2374e99349b9ef7dba9a5db3339b78fda8f34777b1af33ba468ad5c0df946d4d")

	if ht.Assert.Equal(200, w.Code) {
		var actual resource.Transaction
		err := json.Unmarshal(w.Body.Bytes(), &actual)
		ht.Require.NoError(err)

		ht.Assert.Equal(
			"2374e99349b9ef7dba9a5db3339b78fda8f34777b1af33ba468ad5c0df946d4d",
			actual.Hash,
		)
	}

	// missing tx
	w = ht.Get("/transactions/not_real")
	ht.Assert.Equal(404, w.Code)
}

func TestTransactionActions_Index(t *testing.T) {
	ht := StartHTTPTest(t, "base")
	defer ht.Finish()

	w := ht.Get("/transactions")
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.PageOf(4, w.Body)
	}

	// filtered by ledger
	w = ht.Get("/ledgers/1/transactions")
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.PageOf(0, w.Body)
	}

	w = ht.Get("/ledgers/2/transactions")
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.PageOf(3, w.Body)
	}

	w = ht.Get("/ledgers/3/transactions")
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.PageOf(1, w.Body)
	}

	// missing ledger
	w = ht.Get("/ledgers/100/transactions")
	ht.Assert.Equal(404, w.Code)

	// filtering by account
	w = ht.Get("/accounts/GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H/transactions")
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.PageOf(3, w.Body)
	}

	w = ht.Get("/accounts/GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2/transactions")
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.PageOf(1, w.Body)
	}

	w = ht.Get("/accounts/GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU/transactions")
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.PageOf(2, w.Body)
	}

	// regression: https://github.com/stellar/horizon/issues/365
	w = ht.Get("/transactions?limit=200")
	ht.Require.Equal(200, w.Code)
	w = ht.Get("/transactions?limit=201")
	ht.Assert.Equal(400, w.Code)
	w = ht.Get("/transactions?limit=0")
	ht.Assert.Equal(400, w.Code)

}

func TestTransactionActions_Post(t *testing.T) {
	ht := StartHTTPTest(t, "base")
	defer ht.Finish()

	form := url.Values{"tx": []string{"AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAAO5rKAAAAAAAAAAABVvwF9wAAAECDzqvkQBQoNAJifPRXDoLhvtycT3lFPCQ51gkdsFHaBNWw05S/VhW0Xgkr0CBPE4NaFV2Kmcs3ZwLmib4TRrML"}}

	// existing transaction
	w := ht.Post("/transactions", form)
	ht.Assert.Equal(200, w.Code)

	// sequence buffer full
	ht.App.submitter.Results = &txsub.MockResultProvider{
		Results: []txsub.Result{
			{Err: sequence.ErrNoMoreRoom},
		},
	}
	w = ht.Post("/transactions", form)
	ht.Assert.Equal(503, w.Code)
}
