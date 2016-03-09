// Package cache provides various caches used in horizon.
package cache

// Get looks up the History Account ID (i.e. the ID of the operation that
// created the account) for the given strkey encoded address.
func (c *HistoryAccount) Get(address string) (result int64, err error) {
	found, ok := c.cached.Get(address)

	if ok {
		result = found.(int64)
		return
	}

	err = c.db.GetRaw(&result, `
		SELECT id
		FROM history_accounts
		WHERE address = $1
		ORDER BY id DESC
	`, address)

	if err != nil {
		return
	}

	c.cached.Add(address, result)
	return
}
