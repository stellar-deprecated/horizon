package horizon

// HistoryAccountResource is a simple resource, used for the account collection actions.
// It provides only the TotalOrderId of the account and its address.
type HistoryAccountResource struct {
	Id          string `json:"id"`
	PagingToken string `json:"paging_token"`
	Address     string `json:"address"`
}

func (r HistoryAccountResource) SseData() interface{} { return r }
func (r HistoryAccountResource) Err() error           { return nil }
func (r HistoryAccountResource) SseId() string        { return r.PagingToken }
