package db

import (
	"strings"
	"encoding/base64"

	"github.com/guregu/null"
	sq "github.com/lann/squirrel"
	"github.com/stellar/go-stellar-base/xdr"
)

var CoreAccountRecordSelect sq.SelectBuilder = sq.Select(
	"a.accountid",
	"a.balance",
	"a.seqnum",
	"a.numsubentries",
	"a.inflationdest",
	"a.homedomain",
	"a.thresholds",
	"a.flags",
).From("accounts a")

const (
	FlagAuthRequired = 1 << iota
	FlagAuthRevocable = 1 << iota
)

// A row of data from the `accounts` table from stellar-core
type CoreAccountRecord struct {
	Accountid     string
	Balance       int64
	Seqnum        int64
	Numsubentries int32
	Inflationdest null.String
	HomeDomain    null.String
	Thresholds    string
	Flags         int32
}

func (ac CoreAccountRecord) IsAuthRequired() bool {
	return (ac.Flags & FlagAuthRequired) != 0
}

func (ac CoreAccountRecord) IsAuthRevocable() bool {
	return (ac.Flags & FlagAuthRevocable) != 0
}

func (ac CoreAccountRecord) DecodeThresholds() (xdr.Thresholds, error) {
	reader := strings.NewReader(ac.Thresholds)
	b64r := base64.NewDecoder(base64.StdEncoding, reader)
	var xdrThresholds xdr.Thresholds
	_, err := xdr.Unmarshal(b64r, &xdrThresholds)
	return xdrThresholds, err
}
