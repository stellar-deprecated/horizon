// Package cache provides various caches used in horizon.
package cache

import (
	"github.com/stellar/horizon/db"
	hq "github.com/stellar/horizon/db/queries/history"
	"golang.org/x/net/context"
)

// Get looks up the History Account ID (i.e. the ID of the operation that
// created the account) for the given strkey encoded address.
func (c *HistoryAccount) Get(address string) (result int64, err error) {
	found, ok := c.cached.Get(address)

	if ok {
		result = found.(int64)
		return
	}

	q := hq.LatestAccountForAddress{
		DB:      c.db,
		Address: address,
	}

	err = db.Get(context.Background(), &q, &result)
	if err != nil {
		return
	}

	c.cached.Add(address, result)
	return
}
