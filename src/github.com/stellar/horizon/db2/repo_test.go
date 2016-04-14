package db2

import (
	"testing"

	tdb "github.com/stellar/horizon/test/db"
	"github.com/stellar/horizon/test/scenarios"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestRepo(t *testing.T) {
	scenarios.Load(tdb.StellarCoreURL(), "base-core.sql")
	assert := assert.New(t)
	require := require.New(t)
	repo := &Repo{DB: tdb.StellarCore()}

	var count int
	err := repo.GetRaw(&count, "SELECT COUNT(*) FROM txhistory")
	assert.NoError(err)
	assert.Equal(4, count)

	var ids []string
	err = repo.SelectRaw(&ids, "SELECT txid FROM txhistory")
	assert.NoError(err)
	assert.Len(ids, 4)

	ret, err := repo.ExecRaw("DELETE FROM txhistory")
	assert.NoError(err)
	deleted, err := ret.RowsAffected()
	assert.NoError(err)
	assert.Equal(int64(4), deleted)

	// Test args
	var hash string
	err = repo.GetRaw(&hash, "SELECT prevhash FROM ledgerheaders WHERE ledgerseq = ?", 1)
	assert.NoError(err)
	assert.Equal("0000000000000000000000000000000000000000000000000000000000000000", hash)

	// Test NoRows
	err = repo.GetRaw(&hash, "SELECT prevhash FROM ledgerheaders WHERE ledgerseq = ?", 100)
	assert.True(repo.NoRows(err))

	// Test transactions
	require.NoError(repo.Begin(), "begin failed")
	err = repo.GetRaw(&count, "SELECT COUNT(*) FROM ledgerheaders")
	assert.NoError(err)
	assert.Equal(3, count)
	_, err = repo.ExecRaw("DELETE FROM ledgerheaders")
	assert.NoError(err)
	err = repo.GetRaw(&count, "SELECT COUNT(*) FROM ledgerheaders")
	assert.NoError(err)
	assert.Equal(0, count, "Ledgers did not appear deleted inside transaction")
	assert.NoError(repo.Rollback(), "rollback failed")

	// Ensure commit works
	require.NoError(repo.Begin(), "begin failed")
	repo.ExecRaw("DELETE FROM ledgerheaders")
	assert.NoError(repo.Commit(), "commit failed")
	err = repo.GetRaw(&count, "SELECT COUNT(*) FROM ledgerheaders")
	assert.NoError(err)
	assert.Equal(0, count)

	// ensure that selecting into a populated slice clears the slice first
	scenarios.Load(tdb.StellarCoreURL(), "base-core.sql")
	require.Len(ids, 4, "ids slice was not preloaded with data")
	err = repo.SelectRaw(&ids, "SELECT txid FROM txhistory limit 2")
	assert.NoError(err)
	assert.Len(ids, 2)

}
