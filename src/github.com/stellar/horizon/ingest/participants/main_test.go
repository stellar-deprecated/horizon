package participants

import (
	"github.com/stellar/go-stellar-base/network"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/ingest"
	"github.com/stellar/horizon/test"
	"testing"
)

func TestForOperation(t *testing.T) {
	tt := test.Start(t).ScenarioWithoutHorizon("kahuna")
	defer tt.Finish()
	err := ingest.RunOnce(
		network.TestNetworkPassphrase,
		db.SqlQuery{tt.CoreDB},
		db.SqlQuery{tt.HorizonDB},
	)
	tt.Require.NoError(err)

	// test create account
	lb := ingest.LedgerBundle{Sequence: 3}
	err = lb.Load(db.SqlQuery{tt.CoreDB})
	tt.Require.NoError(err)
	op := lb.Transactions[0].Envelope.Tx.Operations[0]
	p, err := ForOperation(&op)
	tt.Require.NoError(err)

	tt.Require.Len(p, 1)
	tt.Assert.Equal("GAXI33UCLQTCKM2NMRBS7XYBR535LLEVAHL5YBN4FTCB4HZHT7ZA5CVK", p[0].Address())

	// test payment
	lb.Sequence = 8
	err = lb.Load(db.SqlQuery{tt.CoreDB})
	tt.Require.NoError(err)
	op = lb.Transactions[0].Envelope.Tx.Operations[0]
	p, err = ForOperation(&op)
	tt.Require.NoError(err)

	tt.Require.Len(p, 1)
	tt.Assert.Equal("GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", p[0].Address())

	// test operation source account set
	op.SourceAccount = &lb.Transactions[0].Envelope.Tx.SourceAccount
	p, err = ForOperation(&op)
	tt.Require.NoError(err)
	tt.Require.Len(p, 2)
	tt.Assert.Equal("GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB", p[0].Address())
	tt.Assert.Equal("GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", p[1].Address())

	// test path payment
	lb.Sequence = 19
	err = lb.Load(db.SqlQuery{tt.CoreDB})
	tt.Require.NoError(err)
	op = lb.Transactions[0].Envelope.Tx.Operations[0]
	p, err = ForOperation(&op)
	tt.Require.NoError(err)

	tt.Require.Len(p, 1)
	tt.Assert.Equal("GACAR2AEYEKITE2LKI5RMXF5MIVZ6Q7XILROGDT22O7JX4DSWFS7FDDP", p[0].Address())

}
