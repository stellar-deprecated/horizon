package horizon

import (
	"errors"
	"fmt"

	"github.com/jagregory/halgo"

	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/render"
	"github.com/stellar/go-horizon/render/hal"
	"github.com/stellar/go-horizon/render/sse"
	"github.com/stellar/go-stellar-base/xdr"
)

var operationResourceTypeNames = map[xdr.OperationType]string{
	xdr.OperationTypeCreateAccount:      "create_account",
	xdr.OperationTypePayment:            "payment",
	xdr.OperationTypePathPayment:        "path_payment",
	xdr.OperationTypeManageOffer:        "manage_offer",
	xdr.OperationTypeCreatePassiveOffer: "create_passive_offer",
	xdr.OperationTypeSetOption:          "set_options",
	xdr.OperationTypeChangeTrust:        "change_trust",
	xdr.OperationTypeAllowTrust:         "allow_trust",
	xdr.OperationTypeAccountMerge:       "account_merge",
	xdr.OperationTypeInflation:          "inflation",
}

type OperationResource map[string]interface{}

// SseEvent converts this resource into a SSE compatible event.  Implements
// the sse.Eventable interface
func (r OperationResource) SseEvent() sse.Event {

	ids, ok := r["paging_token"]

	if !ok {
		return sse.Event{Error: errors.New("paging_token not found in operation resource")}
	}

	return sse.Event{
		Data: r,
		ID:   ids.(string),
	}
}

func operationRecordToResource(record db.Record) (render.Resource, error) {
	op := record.(db.OperationRecord)
	result, err := op.Details()

	if err != nil {
		return nil, err
	}

	self := fmt.Sprintf("/operations/%d", op.Id)

	result["_links"] = halgo.Links{}.
		Self(self).
		Link("transactions", "/transactions/%d", op.TransactionId).
		Link("effects", "%s/effects/%s", self, hal.StandardPagingOptions).
		Link("precedes", "/operations?cursor=%s&order=asc", op.PagingToken()).
		Link("succeeds", "/operations?cursor=%s&order=desc", op.PagingToken()).
		Items
	result["id"] = op.Id
	result["paging_token"] = op.PagingToken()
	result["type"] = op.Type

	ts, ok := operationResourceTypeNames[op.Type]

	if ok {
		result["type_s"] = ts
	} else {
		result["type_s"] = "unknown"
	}

	return result, nil
}
