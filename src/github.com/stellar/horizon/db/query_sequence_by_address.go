package db

import (
	sq "github.com/lann/squirrel"
	"golang.org/x/net/context"
)

type SequenceByAddressQuery struct {
	SqlQuery
	Addresses []string
}

func (q SequenceByAddressQuery) Select(ctx context.Context, dest interface{}) error {
	sql := sq.
		Select("seqnum as sequence", "accountid as address").
		Where(sq.Eq{"accountid": q.Addresses})

	return q.SqlQuery.Select(ctx, sql, dest)
}

// Get implements the txsub.SequenceProvider interface, allowing this query to be used directly for
// providing account sequence numbers for
func (q SequenceByAddressQuery) Get(ctx context.Context, addresses []string) (map[string]uint64, error) {
	q.Addresses = addresses

	rows := []struct {
		Address  string
		Sequence uint64
	}{}

	err := Select(ctx, q, &rows)
	if err != nil {
		return nil, err
	}

	results := make(map[string]uint64)
	for _, r := range rows {
		results[r.Address] = r.Sequence
	}
	return results, nil
}
