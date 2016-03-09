package db2

import (
	"testing"

	tdb "github.com/stellar/horizon/test/db"
	"github.com/stellar/horizon/test/scenarios"
	"github.com/stretchr/testify/assert"
)

func TestRepo(t *testing.T) {
	scenarios.Load(tdb.StellarCoreURL(), "base-core.sql")
	assert := assert.New(t)
	repo := &Repo{Conn: tdb.StellarCore()}

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
}
