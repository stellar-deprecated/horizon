package horizon

import "github.com/stellar/go-horizon/render/sse"

// HistoryAccountResource is a simple resource, used for the account collection actions.
// It provides only the TotalOrderId of the account and its address.
type HistoryAccountResource struct {
	ID          string `json:"id"`
	PagingToken string `json:"paging_token"`
	Address     string `json:"address"`
}

// SseEvent converts this resource into a SSE compatible event.  Implements
// the sse.Eventable interface
func (r HistoryAccountResource) SseEvent() sse.Event {
	return sse.Event{
		Data: r,
		ID:   r.PagingToken,
	}
}
