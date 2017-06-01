package history

import "github.com/pkg/errors"

// LoadLedgers loads a batch of ledger data from either the cache or the
// database.
func (lc *LedgerCache) LoadLedgers(
	lss []LedgerSequencer,
) (LedgerMap, error) {

	toload := map[int32]struct{}{}
	result := LedgerMap{}

	// get a read lock, and populate any cached results
	lc.lock.RLock()
	for _, ls := range lss {
		seq := ls.GetLedgerSequence()
		found, ok := lc.cache[seq]

		if ok {
			result[seq] = found
		} else {
			toload[seq] = struct{}{}
		}
	}
	lc.lock.RUnlock()

	// load the uncached ledgers
	ledgerSequences := make([]interface{}, 0, len(toload))

	for seq := range toload {
		ledgerSequences = append(ledgerSequences, seq)
	}

	var ledgers []Ledger
	err := lc.DB.LedgersBySequence(
		&ledgers,
		ledgerSequences...,
	)

	if err != nil {
		return nil, errors.Wrap(err, "db load failed")
	}

	// populate cache and result with loaded values
	lc.lock.Lock()
	defer lc.lock.Unlock()

	for _, l := range ledgers {
		lc.cache[l.Sequence] = l
		result[l.Sequence] = l
	}

	// return the result
	return result, nil
}
