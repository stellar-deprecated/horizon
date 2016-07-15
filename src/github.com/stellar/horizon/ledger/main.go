// Package ledger provides useful utilities concerning ledgers within stellar,
// specifically a central location to store a cached snapshot of the state of
// both horizon's and stellar-core's view of the ledger.  This package is
// intended to be at the lowest levels of horizon's dependency tree, please keep
// it free of dependencies to other horizon packages.
package ledger

import (
	"sync"
)

// State represents a snapshot of both horizon's and stellar-core's view of the
// ledger.
type State struct {
	CoreLatest    int32 `db:"core_latest"`
	CoreElder     int32 `db:"core_elder"`
	HorizonLatest int32 `db:"horizon_latest"`
	HorizonElder  int32 `db:"horizon_elder"`
}

// CurrentState returns the cached snapshot of ledger state
func CurrentState() State {
	lock.RLock()
	ret := current
	lock.RUnlock()
	return ret
}

// SetState updates the cached snapshot of the ledger state
func SetState(next State) {
	lock.Lock()
	current = next
	lock.Unlock()
}

var current State
var lock sync.RWMutex
