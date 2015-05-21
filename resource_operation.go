package horizon

import (
	"fmt"

	"github.com/jagregory/halgo"

	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render"
	"github.com/stellar/go-horizon/render/sse"
)

// PaymentResource contains the payment specific details for a payment operation
type PaymentResource struct {
	OperationResource
	From   string `json:"from"`
	To     string `json:"to"`
	Amount string `json:"amount"`
}

// SseEvent converts this resource into a SSE compatible event.  Implements
// the sse.Eventable interface
func (r PaymentResource) SseEvent() sse.Event {
	return sse.Event{
		Data: r,
		ID:   r.PagingToken,
	}
}

// OperationResource is the display form of an operation.
type OperationResource struct {
	halgo.Links
	ID          int64  `json:"id"`
	PagingToken string `json:"paging_token"`
	Type        int32  `json:"type"`
	TypeString  string `json:"type_s"`
}

// SseEvent converts this resource into a SSE compatible event.  Implements
// the sse.Eventable interface
func (r OperationResource) SseEvent() sse.Event {
	return sse.Event{
		Data: r,
		ID:   r.PagingToken,
	}
}

func operationRecordToResource(record db.Record) (result render.Resource, err error) {

	op := record.(db.OperationRecord)
	self := fmt.Sprintf("/operations/%d", op.Id)
	po := "{?cursor}{?limit}{?order}"

	common := OperationResource{
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

	// TODO: use the constant from go-stellar-base, when it exists
	if op.Type == 1 {
		result = PaymentResource{
			OperationResource: common,
			From:              op.Details.Map["from"].String,
			To:                op.Details.Map["to"].String,
			Amount:            op.Details.Map["amount"].String,
		}
	} else {
		result = common
	}

	return
}
