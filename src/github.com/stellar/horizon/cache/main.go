// Package cache provides various caches used in horizon.
package cache

import (
	"github.com/golang/groupcache/lru"
	"github.com/stellar/horizon/db"
)

// HistoryAccount provides a cached lookup of history_account_id values from
// account addresses.
type HistoryAccount struct {
	db     db.SqlQuery
	cached *lru.Cache
}

func NewHistoryAccount(db db.SqlQuery) *HistoryAccount {
	return &HistoryAccount{
		db:     db,
		cached: lru.New(100),
	}
}
