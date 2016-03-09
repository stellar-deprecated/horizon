// Package cache provides various caches used in horizon.
package cache

import (
	"github.com/golang/groupcache/lru"
	"github.com/stellar/horizon/db2"
)

// HistoryAccount provides a cached lookup of history_account_id values from
// account addresses.
type HistoryAccount struct {
	db     *db2.Repo
	cached *lru.Cache
}

// NewHistoryAccount initializes a new instance of `HistoryAccount`
func NewHistoryAccount(db *db2.Repo) *HistoryAccount {
	return &HistoryAccount{
		db:     db,
		cached: lru.New(100),
	}
}
