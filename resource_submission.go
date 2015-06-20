package horizon

import "github.com/jagregory/halgo"

// SubmissionResource is a resource that represents the state of a transaction
type SubmissionResource struct {
	halgo.Links
	Hash string `json:"hash"`
}

func NewSubmissionResource(hash string) (result SubmissionResource) {

	result.Hash = hash

	//TODO: if transaction is in history story, add a link to the links collection

	return
}
