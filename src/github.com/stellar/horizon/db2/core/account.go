package core

import (
	sq "github.com/lann/squirrel"
	"github.com/stellar/go-stellar-base/xdr"
)

// IsAuthRequired returns true if the account has the "AUTH_REQUIRED" option
// turned on.
func (ac Account) IsAuthRequired() bool {
	return (ac.Flags & xdr.AccountFlagsAuthRequiredFlag) != 0
}

// IsAuthRevocable returns true if the account has the "AUTH_REVOCABLE" option
// turned on.
func (ac Account) IsAuthRevocable() bool {
	return (ac.Flags & xdr.AccountFlagsAuthRevocableFlag) != 0
}

// SequencesForAddresses loads the current sequence number for every accountid
// specified in `addys`
func (q *Q) SequencesForAddresses(dest interface{}, addys []string) error {
	sql := sq.
		Select("seqnum as sequence", "accountid as address").
		From("accounts").
		Where(sq.Eq{"accountid": addys})

	return q.Select(dest, sql)
}

// SequenceProvider returns a new sequence provider.
func (q *Q) SequenceProvider() *SequenceProvider {
	return &SequenceProvider{Q: q}
}

// Get implements `txsub.SequenceProvider`
func (sp *SequenceProvider) Get(addys []string) (map[string]uint64, error) {
	rows := []struct {
		Address  string
		Sequence uint64
	}{}

	err := sp.Q.SequencesForAddresses(&rows, addys)
	if err != nil {
		return nil, err
	}

	results := make(map[string]uint64)
	for _, r := range rows {
		results[r.Address] = r.Sequence
	}
	return results, nil
}
