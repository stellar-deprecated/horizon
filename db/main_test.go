package db

import (
	"errors"
	"fmt"
	"testing"

	"golang.org/x/net/context"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
)

func TestDBOpen(t *testing.T) {
	Convey("db.Open", t, func() {
		// TODO
	})
}

func TestDBPackage(t *testing.T) {
	test.LoadScenario("non_native_payment")
	ctx := test.Context()
	core := OpenStellarCoreTestDatabase()
	defer core.Close()

	Convey("db.Results", t, func() {
		query := &mockQuery{2}
		results, err := Results(ctx, query)
		So(err, ShouldBeNil)
		So(len(results), ShouldEqual, 2)
	})

	Convey("db.Select", t, func() {
		Convey("overwrites the destination", func() {
			records := []mockResult{{1}, {2}}
			query := &mockQuery{5}
			err := Select(ctx, query, &records)
			So(err, ShouldBeNil)
			So(len(records), ShouldEqual, 5)
		})

		Convey("works on []interface{} destinations", func() {
			var records []interface{}
			query := &mockQuery{5}
			err := Select(ctx, query, &records)
			So(err, ShouldBeNil)
			So(len(records), ShouldEqual, 5)
		})

		Convey("returns an error when the provided destination is nil", func() {
			query := &mockQuery{5}
			err := Select(ctx, query, nil)
			So(err, ShouldEqual, ErrDestinationNil)
		})

		Convey("returns an error when the provided destination is not a pointer", func() {
			var records []mockResult
			query := &mockQuery{5}
			err := Select(ctx, query, records)
			So(err, ShouldEqual, ErrDestinationNotPointer)
		})

		Convey("returns an error when the provided destination is not a slice", func() {
			var records string
			query := &mockQuery{5}
			err := Select(ctx, query, &records)
			So(err, ShouldEqual, ErrDestinationNotSlice)
		})

		Convey("returns an error when the provided destination is a slice of an invalid type", func() {
			var records []string
			query := &mockQuery{5}
			err := Select(ctx, query, &records)
			So(err, ShouldNotBeNil)
		})
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
	fmt.Printf("%s", account.Accountid)
	// Output: gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC
}

func ExampleSelect() {
	db := OpenStellarCoreTestDatabase()
	defer db.Close()

	q := CoreAccountByAddressQuery{
		SqlQuery{db},
		"gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC",
	}

	var records []CoreAccountRecord
	err := Select(context.Background(), q, &records)

	if err != nil {
		panic(err)
	}

	fmt.Printf("%d", len(records))
	// Output: 1
}
