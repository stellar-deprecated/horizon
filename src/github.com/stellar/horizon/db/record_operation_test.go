package db

import (
	"testing"

	."github.com/smartystreets/goconvey/convey"

)

func TestOperationRecord(t *testing.T) {

    Convey("Should be able to set the Id of OperationRecord", t, func() {
        record := new(OperationRecord)
        record.Id = 5
        So(record.Id, ShouldEqual, 5)
        Convey("PagingToken() returns an id ", func() {
            So(record.PagingToken(), ShouldEqual, "5")
		    })
	    })
}