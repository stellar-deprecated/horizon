package db

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
)

func TestCoreOfferPageByAddressQuery(t *testing.T) {
	test.LoadScenario("trades")

	Convey("CoreOfferPageByAddressQuery", t, func() {

		makeQuery := func(c string, o string, l int32, a string) CoreOfferPageByAddressQuery {
			pq, err := NewPageQuery(c, o, l)

			So(err, ShouldBeNil)

			return CoreOfferPageByAddressQuery{
				SqlQuery:  SqlQuery{core},
				PageQuery: pq,
				Address:   a,
			}
		}

		var records []CoreOfferRecord

		Convey("works with native offers", func() {
			MustSelect(ctx, makeQuery("", "asc", 0, "gZdw35byFspxLHeLAGBq8r1hYrUWVaSe3jrBnEgUq1Ai8C59ec"), &records)
			So(len(records), ShouldEqual, 1)
		})

		Convey("filters properly", func() {
			MustSelect(ctx, makeQuery("", "desc", 0, "gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC"), &records)
			So(len(records), ShouldEqual, 0)

			MustSelect(ctx, makeQuery("", "asc", 0, "gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm"), &records)
			So(len(records), ShouldEqual, 3)

		})

		Convey("orders properly", func() {
			// asc orders ascending by id
			MustSelect(ctx, makeQuery("", "asc", 0, "gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm"), &records)

			So(records, ShouldBeOrderedAscending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, CoreOfferRecord{})
				return r.(CoreOfferRecord).Offerid
			})

			// desc orders descending by id
			MustSelect(ctx, makeQuery("", "desc", 0, "gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm"), &records)

			So(records, ShouldBeOrderedDescending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, CoreOfferRecord{})
				return r.(CoreOfferRecord).Offerid
			})
		})

		Convey("limits properly", func() {
			// returns number specified
			MustSelect(ctx, makeQuery("", "asc", 2, "gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm"), &records)
			So(len(records), ShouldEqual, 2)

			// returns all rows if limit is higher
			MustSelect(ctx, makeQuery("", "asc", 10, "gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm"), &records)
			So(len(records), ShouldEqual, 3)
		})

		Convey("cursor works properly", func() {
			var record CoreOfferRecord
			// lowest id if ordered ascending and no cursor
			MustGet(ctx, makeQuery("", "asc", 0, "gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm"), &record)
			So(record.Offerid, ShouldEqual, 1)

			// highest id if ordered descending and no cursor
			MustGet(ctx, makeQuery("", "desc", 0, "gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm"), &record)
			So(record.Offerid, ShouldEqual, 3)

			// starts after the cursor if ordered ascending
			MustGet(ctx, makeQuery("1", "asc", 0, "gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm"), &record)
			So(record.Offerid, ShouldEqual, 2)

			// starts before the cursor if ordered descending
			MustGet(ctx, makeQuery("3", "desc", 0, "gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm"), &record)
			So(record.Offerid, ShouldEqual, 2)
		})

	})
}
