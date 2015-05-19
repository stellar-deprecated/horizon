package db

import (
	"errors"
	"log"
	"testing"

	"golang.org/x/net/context"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
)

func TestDBPackage(t *testing.T) {
	ctx := test.Context()

	Convey("db.Open", t, func() {
		// TODO
	})

	Convey("db.Results", t, func() {
		query := &mockQuery{2}

		results, err := Results(ctx, query)

		So(err, ShouldBeNil)
		So(len(results), ShouldEqual, 2)
	})

	Convey("db.First", t, func() {
		Convey("returns the first record", func() {
			query := &mockQuery{2}
			output, err := First(ctx, query)
			So(err, ShouldBeNil)
			So(output.(mockResult), ShouldResemble, mockResult{0})
		})

		Convey("Missing records returns nil", func() {
			query := &mockQuery{0}
			output, err := First(ctx, query)
			So(err, ShouldBeNil)
			So(output, ShouldBeNil)
		})

		Convey("Properly forwards non-RecordNotFound errors", func() {
			query := &BrokenQuery{errors.New("Some error")}
			_, err := First(ctx, query)

			So(err, ShouldNotBeNil)
			So(err.Error(), ShouldEqual, "Some error")
		})
	})
}

func ExampleFirst() {
	db := OpenStellarCoreTestDatabase()
	defer db.Close()

	q := CoreAccountByAddressQuery{
		SqlQuery{db},
		"gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC",
	}

	record, err := First(context.Background(), q)

	if err != nil {
		panic(err)
	}

	account := record.(CoreAccountRecord)
	log.Println(account.Accountid)

}
