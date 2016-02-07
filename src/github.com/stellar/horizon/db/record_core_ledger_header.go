package db

import (
	// "database/sql"
	sq "github.com/lann/squirrel"
	// "golang.org/x/net/context"
)

var CoreLedgerHeaderRecordSelect = sq.Select("clh.*").From("ledgerheaders clh")
