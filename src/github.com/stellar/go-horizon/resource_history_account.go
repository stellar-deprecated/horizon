package horizon

import (
	"github.com/jagregory/halgo"
	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render/hal"
)

// HistoryAccountResource is a simple resource, used for the account collection actions.
// It provides only the TotalOrderId of the account and its address.
type HistoryAccountResource struct {
	ID          string `json:"id"`
	PagingToken string `json:"paging_token"`
	Address     string `json:"address"`
}

// NewHistoryAccountResource creates a new resource from a db.HistoryAccountRecord
func NewHistoryAccountResource(in db.HistoryAccountRecord) HistoryAccountResource {
	return HistoryAccountResource{
		ID:          in.Address,
		PagingToken: in.PagingToken(),
		Address:     in.Address,
	}
}

//NewHistoryAccountResourcePage creates a page of HistoryAccountResources
func NewHistoryAccountResourcePage(records []db.HistoryAccountRecord, query db.PageQuery) (hal.Page, error) {
	fmts := "/accounts?order=%s&limit=%d&cursor=%s"
	next, prev, err := query.GetContinuations(records)
	if err != nil {
		return hal.Page{}, err
	}

	resources := make([]interface{}, len(records))
	for i, record := range records {
		resources[i] = NewHistoryAccountResource(record)
	}

	return hal.Page{
		Links: halgo.Links{}.
			Self(fmts, query.Order, query.Limit, query.Cursor).
			Link("next", fmts, next.Order, next.Limit, next.Cursor).
			Link("prev", fmts, prev.Order, prev.Limit, prev.Cursor),
		Records: resources,
	}, nil
}
