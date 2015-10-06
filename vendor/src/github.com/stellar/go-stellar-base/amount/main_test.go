package amount_test

import (
	"github.com/stellar/go-stellar-base/amount"
	"github.com/stellar/go-stellar-base/xdr"
	"testing"
)

var Tests = []struct {
	S string
	I xdr.Int64
}{
	{"100.0000000", 1000000000},
	{"100.0000001", 1000000001},
	{"123.0000001", 1230000001},
}

func TestParse(t *testing.T) {
	for _, v := range Tests {
		o, err := amount.Parse(v.S)
		if err != nil {
			t.Errorf("Couldn't parse %s: %v+", v.S, err)
			continue
		}

		if o != v.I {
			t.Errorf("%s parsed to %d, not %d", v.S, o, v.I)
		}
	}
}

func TestString(t *testing.T) {
	for _, v := range Tests {
		o := amount.String(v.I)

		if o != v.S {
			t.Errorf("%d stringified to %s, not %s", v.I, o, v.S)
		}
	}
}
