package horizon

import (
	"fmt"

	"github.com/jagregory/halgo"

	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render"
)

// OperationResource is the display form of an operation.
type OperationResource struct {
	halgo.Links
	ID          int64  `json:"id"`
	PagingToken string `json:"paging_token"`
	Type        int32  `json:"type"`
	TypeString  string `json:"type_s"`
}

func (r OperationResource) SseData() interface{} { return r }
func (r OperationResource) Err() error           { return nil }
func (r OperationResource) SseId() string        { return r.PagingToken }

func operationRecordToResource(record db.Record) (render.Resource, error) {
	op := record.(db.OperationRecord)
	self := fmt.Sprintf("/operations/%d", op.Id)
	po := "{?cursor}{?limit}{?order}"

	resource := OperationResource{
		Links: halgo.Links{}.
			Self(self).
			Link("transactions", "/transactions/%d", op.TransactionId).
			Link("effects", "%s/effects/%s", self, po).
			Link("precedes", "/operations?cursor=%s&order=asc", op.PagingToken()).
			Link("succeeds", "/operations?cursor=%s&order=desc", op.PagingToken()),
		ID:          op.Id,
		PagingToken: op.PagingToken(),
		Type:        op.Type,
		TypeString:  "TODO",
	}

	return resource, nil
}
