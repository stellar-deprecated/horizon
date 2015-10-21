package simplepath

import (
	"errors"
	sq "github.com/lann/squirrel"
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/assets"
	"github.com/stellar/horizon/db"
	"golang.org/x/net/context"
	"math/big"
)

var ErrNotEnough = errors.New("not enough depth")

type orderBook struct {
	Selling xdr.Asset
	Buying  xdr.Asset
	DB      db.SqlQuery
}

func (ob *orderBook) Cost(source xdr.Asset, sourceAmount xdr.Int64) (result xdr.Int64, err error) {
	// load offers from the two assets

	var (
		// selling/buying types
		st, bt xdr.AssetType
		// selling/buying codes
		sc, bc string
		// selling/buying issuers
		si, bi string
	)

	err = ob.Selling.Extract(&st, &sc, &si)
	if err != nil {
		return
	}

	err = ob.Buying.Extract(&bt, &bc, &bi)
	if err != nil {
		return
	}

	sql := sq.
		Select("amount", "pricen", "priced", "offerid").
		From("offers").
		Where(sq.Eq{"sellingassettype": st, "sellingassetcode": sc, "sellingissuer": si}).
		Where(sq.Eq{"buyingassettype": bt, "buyingassetcode": bc, "buyingissuer": bi})

	inverted := assets.Equals(source, ob.Buying)

	if !inverted {
		sql = sql.OrderBy("price ASC")
	} else {
		sql = sql.OrderBy("price DESC")
	}

	rows, err := ob.DB.Query(context.TODO(), sql)
	if err != nil {
		return
	}
	defer rows.Close()

	var (
		needed int64 = int64(sourceAmount)
		cost   int64 = 0
	)

	for rows.Next() {
		// load data from the row
		var available, pricen, priced, offerid int64
		if inverted {
			err = rows.Scan(&available, &priced, &pricen, &offerid)
			available = mul(available, pricen, priced)
		} else {
			err = rows.Scan(&available, &pricen, &priced, &offerid)
		}
		if err != nil {
			return
		}

		if available >= needed {
			cost += mul(needed, pricen, priced)
			result = xdr.Int64(cost)
			return
		}

		cost += mul(available, pricen, priced)
		needed -= available
	}

	err = ErrNotEnough
	return
}

// mul multiplies the input amount by the input price
func mul(amount int64, pricen int64, priced int64) int64 {
	var r, n, d big.Int

	r.SetInt64(amount)
	n.SetInt64(pricen)
	d.SetInt64(priced)

	r.Mul(&r, &n)
	r.Quo(&r, &d)
	return r.Int64()
}
