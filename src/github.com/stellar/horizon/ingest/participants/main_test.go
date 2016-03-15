package participants

import (
	"testing"

	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/db2/core"
	"github.com/stellar/horizon/test"
)

func TestForOperation(t *testing.T) {
	tt := test.Start(t).ScenarioWithoutHorizon("kahuna")
	defer tt.Finish()
	q := &core.Q{tt.CoreRepo()}

	load := func(lg int32, tx int, op int) []xdr.AccountId {
		var txs []core.Transaction

		err := q.TransactionsByLedger(&txs, lg)
		tt.Require.NoError(err, "failed to load transaction data")
		xtx := txs[tx].Envelope.Tx
		xop := xtx.Operations[op]
		ret, err := ForOperation(&xtx, &xop)
		tt.Require.NoError(err, "ForOperation() errored")
		return ret
	}

	// test create account
	p := load(3, 0, 0)
	tt.Require.Len(p, 2)
	tt.Assert.Equal("GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", p[0].Address())
	tt.Assert.Equal("GAXI33UCLQTCKM2NMRBS7XYBR535LLEVAHL5YBN4FTCB4HZHT7ZA5CVK", p[1].Address())

	// test payment
	p = load(8, 0, 0)
	tt.Require.Len(p, 2)
	tt.Assert.Equal("GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB", p[0].Address())
	tt.Assert.Equal("GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", p[1].Address())

	// test path payment
	p = load(19, 0, 0)
	tt.Require.Len(p, 2)
	tt.Assert.Equal("GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD", p[0].Address())
	tt.Assert.Equal("GACAR2AEYEKITE2LKI5RMXF5MIVZ6Q7XILROGDT22O7JX4DSWFS7FDDP", p[1].Address())

	// test manage offer
	p = load(18, 2, 0)
	tt.Assert.Len(p, 1)
	tt.Assert.Equal("GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU", p[0].Address())

	// test passive offer
	p = load(26, 0, 0)
	tt.Assert.Len(p, 1)
	tt.Assert.Equal("GB6GN3LJUW6JYR7EDOJ47VBH7D45M4JWHXGK6LHJRAEI5JBSN2DBQY7Q", p[0].Address())

	// test set options
	p = load(28, 0, 0)
	tt.Assert.Len(p, 1)
	tt.Assert.Equal("GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES", p[0].Address())

	// test change trust
	p = load(17, 0, 0)
	tt.Assert.Len(p, 1)
	tt.Assert.Equal("GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD", p[0].Address())

	// test allow trust
	p = load(38, 0, 0)
	tt.Require.Len(p, 2)
	tt.Assert.Equal("GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF", p[0].Address())
	tt.Assert.Equal("GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG", p[1].Address())

	// test account merge
	p = load(41, 0, 0)
	tt.Require.Len(p, 2)
	tt.Assert.Equal("GCHPXGVDKPF5KT4CNAT7X77OXYZ7YVE4JHKFDUHCGCVWCL4K4PQ67KKZ", p[0].Address())
	tt.Assert.Equal("GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", p[1].Address())

	// test inflation
	p = load(42, 0, 0)
	tt.Assert.Len(p, 1)
	tt.Assert.Equal("GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", p[0].Address())

	// test manage data
	p = load(44, 0, 0)
	tt.Assert.Len(p, 1)
	tt.Assert.Equal("GAYSCMKQY6EYLXOPTT6JPPOXDMVNBWITPTSZIVWW4LWARVBOTH5RTLAD", p[0].Address())
}

func TestForTransaction(t *testing.T) {
	tt := test.Start(t).ScenarioWithoutHorizon("kahuna")
	defer tt.Finish()
	q := &core.Q{tt.CoreRepo()}

	load := func(lg int32, tx int, op int) []xdr.AccountId {
		var txs []core.Transaction
		var fees []core.TransactionFee
		err := q.TransactionsByLedger(&txs, lg)
		tt.Require.NoError(err, "failed to load transaction data")
		err = q.TransactionFeesByLedger(&fees, lg)
		tt.Require.NoError(err, "failed to load transaction fee data")

		xtx := txs[tx].Envelope.Tx
		meta := txs[tx].ResultMeta
		fee := fees[tx].Changes

		ret, err := ForTransaction(&xtx, &meta, &fee)
		tt.Require.NoError(err, "ForOperation() errored")
		return ret
	}

	p := load(3, 0, 0)
	tt.Require.Len(p, 2)
	tt.Assert.Equal("GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", p[0].Address())
	tt.Assert.Equal("GAXI33UCLQTCKM2NMRBS7XYBR535LLEVAHL5YBN4FTCB4HZHT7ZA5CVK", p[1].Address())

}
