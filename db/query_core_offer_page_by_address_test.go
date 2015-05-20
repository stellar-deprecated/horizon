package db

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-horizon/test"
)

func TestCoreOfferPageByAddressQuery(t *testing.T) {
	test.LoadScenario("trades")
	ctx := test.Context()
	db := OpenStellarCoreTestDatabase()
	defer db.Close()

	Convey("CoreOfferPageByAddressQuery", t, func() {
		makeQuery := func(c string, o string, l int32, a string) CoreOfferPageByAddressQuery {
			pq, err := NewPageQuery(c, o, l)

			So(err, ShouldBeNil)

			return CoreOfferPageByAddressQuery{
				SqlQuery:  SqlQuery{db},
				PageQuery: pq,
				Address:   a,
			}
		}

		Convey("filters properly", func() {
			records := MustResults(ctx, makeQuery("", "asc", 0, "gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ"))
			So(len(records), ShouldEqual, 3)

			records = MustResults(ctx, makeQuery("", "desc", 0, "gQXzHmovfMDqQpfVLUqrw46nnrRAJ6EVBDUiQtCTwJ5vxzceT1"))
			So(len(records), ShouldEqual, 0)
		})

		Convey("orders properly", func() {
			// asc orders ascending by id
			records := MustResults(ctx, makeQuery("", "asc", 0, "gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ"))

			So(records, ShouldBeOrderedAscending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, CoreOfferRecord{})
				return r.(CoreOfferRecord).Offerid
			})

			// desc orders descending by id
			records = MustResults(ctx, makeQuery("", "desc", 0, "gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ"))

			So(records, ShouldBeOrderedDescending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, CoreOfferRecord{})
				return r.(CoreOfferRecord).Offerid
			})
		})

		Convey("limits properly", func() {
			// returns number specified
			records := MustResults(ctx, makeQuery("", "asc", 2, "gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ"))
			So(len(records), ShouldEqual, 2)

			// returns all rows if limit is higher
			records = MustResults(ctx, makeQuery("", "asc", 10, "gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ"))
			So(len(records), ShouldEqual, 3)
		})

		Convey("cursor works properly", func() {
			// lowest id if ordered ascending and no cursor
			record := MustFirst(ctx, makeQuery("", "asc", 0, "gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ"))
			So(record.(CoreOfferRecord).Offerid, ShouldEqual, 1)

			// highest id if ordered descending and no cursor
			record = MustFirst(ctx, makeQuery("", "desc", 0, "gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ"))
			So(record.(CoreOfferRecord).Offerid, ShouldEqual, 3)

			// starts after the cursor if ordered ascending
			record = MustFirst(ctx, makeQuery("1", "asc", 0, "gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ"))
			So(record.(CoreOfferRecord).Offerid, ShouldEqual, 2)

			// starts before the cursor if ordered descending
			record = MustFirst(ctx, makeQuery("3", "desc", 0, "gsCbEtDc7pGew7KPufNKtvGuhQCRwc7M3V5MbETzpFMDRvaqCeZ"))
			So(record.(CoreOfferRecord).Offerid, ShouldEqual, 2)
		})

	})
}
