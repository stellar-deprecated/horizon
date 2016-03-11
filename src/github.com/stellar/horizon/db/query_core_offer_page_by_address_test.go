package db

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/db2/core"
	"github.com/stellar/horizon/test"
)

func TestCoreOfferPageByAddressQuery(t *testing.T) {
	test.LoadScenario("trades")

	Convey("CoreOfferPageByAddressQuery", t, func() {

		makeQuery := func(c string, o string, l int32, a string) CoreOfferPageByAddressQuery {
			pq, err := NewPageQuery(c, o, l)

			So(err, ShouldBeNil)

			return CoreOfferPageByAddressQuery{
				SqlQuery:  SqlQuery{coreDb},
				PageQuery: pq,
				Address:   a,
			}
		}

		var records []core.Offer

		Convey("works with native offers", func() {
			MustSelect(ctx, makeQuery("", "asc", 0, "GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU"), &records)
			So(len(records), ShouldEqual, 1)
		})

		Convey("filters properly", func() {
			MustSelect(ctx, makeQuery("", "desc", 0, "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"), &records)
			So(len(records), ShouldEqual, 0)

			MustSelect(ctx, makeQuery("", "asc", 0, "GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2"), &records)
			So(len(records), ShouldEqual, 3)

		})

		Convey("orders properly", func() {
			// asc orders ascending by id
			MustSelect(ctx, makeQuery("", "asc", 0, "GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2"), &records)

			So(records, ShouldBeOrderedAscending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, core.Offer{})
				return r.(core.Offer).OfferID
			})

			// desc orders descending by id
			MustSelect(ctx, makeQuery("", "desc", 0, "GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2"), &records)

			So(records, ShouldBeOrderedDescending, func(r interface{}) int64 {
				So(r, ShouldHaveSameTypeAs, core.Offer{})
				return r.(core.Offer).OfferID
			})
		})

		Convey("limits properly", func() {
			// returns number specified
			MustSelect(ctx, makeQuery("", "asc", 2, "GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2"), &records)
			So(len(records), ShouldEqual, 2)

			// returns all rows if limit is higher
			MustSelect(ctx, makeQuery("", "asc", 10, "GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2"), &records)
			So(len(records), ShouldEqual, 3)
		})

		Convey("cursor works properly", func() {
			var record core.Offer
			// lowest id if ordered ascending and no cursor
			MustGet(ctx, makeQuery("", "asc", 0, "GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2"), &record)
			So(record.OfferID, ShouldEqual, 1)

			// highest id if ordered descending and no cursor
			MustGet(ctx, makeQuery("", "desc", 0, "GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2"), &record)
			So(record.OfferID, ShouldEqual, 3)

			// starts after the cursor if ordered ascending
			MustGet(ctx, makeQuery("1", "asc", 0, "GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2"), &record)
			So(record.OfferID, ShouldEqual, 2)

			// starts before the cursor if ordered descending
			MustGet(ctx, makeQuery("3", "desc", 0, "GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2"), &record)
			So(record.OfferID, ShouldEqual, 2)
		})

	})
}
