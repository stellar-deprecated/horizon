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

		Convey("works with native offers", func() {
			records := MustResults(ctx, makeQuery("", "asc", 0, "gZdw35byFspxLHeLAGBq8r1hYrUWVaSe3jrBnEgUq1Ai8C59ec"))
			So(len(records), ShouldEqual, 1)
		})

		Convey("filters properly", func() {
			records := MustResults(ctx, makeQuery("", "asc", 0, "gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm"))
			So(len(records), ShouldEqual, 3)

			records = MustResults(ctx, makeQuery("", "desc", 0, "gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC"))
			So(len(records), ShouldEqual, 0)
		})

		Convey("orders properly", func() {
			// asc orders ascending by id
			records := MustResults(ctx, makeQuery("", "asc", 0, "gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm"))

			So(records, ShouldBeOrderedAscending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, CoreOfferRecord{})
				return r.(CoreOfferRecord).Offerid
			})

			// desc orders descending by id
			records = MustResults(ctx, makeQuery("", "desc", 0, "gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm"))

			So(records, ShouldBeOrderedDescending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, CoreOfferRecord{})
				return r.(CoreOfferRecord).Offerid
			})
		})

		Convey("limits properly", func() {
			// returns number specified
			records := MustResults(ctx, makeQuery("", "asc", 2, "gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm"))
			So(len(records), ShouldEqual, 2)

			// returns all rows if limit is higher
			records = MustResults(ctx, makeQuery("", "asc", 10, "gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm"))
			So(len(records), ShouldEqual, 3)
		})

		Convey("cursor works properly", func() {
			// lowest id if ordered ascending and no cursor
			record := MustFirst(ctx, makeQuery("", "asc", 0, "gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm"))
			So(record.(CoreOfferRecord).Offerid, ShouldEqual, 1)

			// highest id if ordered descending and no cursor
			record = MustFirst(ctx, makeQuery("", "desc", 0, "gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm"))
			So(record.(CoreOfferRecord).Offerid, ShouldEqual, 3)

			// starts after the cursor if ordered ascending
			record = MustFirst(ctx, makeQuery("1", "asc", 0, "gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm"))
			So(record.(CoreOfferRecord).Offerid, ShouldEqual, 2)

			// starts before the cursor if ordered descending
			record = MustFirst(ctx, makeQuery("3", "desc", 0, "gHnJZDwXAHNYxHBkv1x5iGy2kqYkyRXqmSxdAZyuydzrTgGiwm"))
			So(record.(CoreOfferRecord).Offerid, ShouldEqual, 2)
		})

	})
}
