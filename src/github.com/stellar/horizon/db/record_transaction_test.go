package db

import (
	"testing"

	."github.com/smartystreets/goconvey/convey"

)

func TestTransactionRecord(t *testing.T) {

    Convey("Should be able to set the Id of TransactionRecord", t, func() {
        record := new(TransactionRecord)
        record.Id = 5
        So(record.Id, ShouldEqual, 5)
        Convey("PagingToken() returns an id ", func() {
            So(record.PagingToken(), ShouldEqual, "5")
		    })
	    })
}