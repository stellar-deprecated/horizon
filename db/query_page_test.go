package db

import (
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
)

func TestPageQuery(t *testing.T) {
	Convey("NewPageQuery", t, func() {

		Convey("Sets attributes correctly", func() {
			p, err := NewPageQuery("10", "desc", 15)
			So(err, ShouldBeNil)
			So(p.Cursor, ShouldEqual, 10)
			So(p.Order, ShouldEqual, "desc")
			So(p.Limit, ShouldEqual, 15)
		})

		Convey("Defaults to ordered asc", func() {
			p, err := NewPageQuery("", "", 0)
			So(err, ShouldBeNil)
			So(p.Order, ShouldEqual, "asc")
		})

		Convey("Errors when order is not 'asc' ord 'desc'", func() {
			_, err := NewPageQuery("", "foo", 0)
			So(err, ShouldEqual, ErrInvalidOrder)
		})

		Convey("Defaults to 0 when ordered asc", func() {
			p, err := NewPageQuery("", "asc", 0)
			So(err, ShouldBeNil)
			So(p.Cursor, ShouldEqual, 0)
		})

		Convey("Defaults to MaxInt64 when ordered desc", func() {
			p, err := NewPageQuery("", "desc", 0)
			So(err, ShouldBeNil)
			So(p.Cursor, ShouldEqual, 9223372036854775807)
		})

		Convey("Errors when cursor is not parseable as a number", func() {
			_, err := NewPageQuery("not_a_number", "", 0)
			So(err, ShouldEqual, ErrInvalidCursor)
		})

		Convey("Errors when cursor is less than zero", func() {
			_, err := NewPageQuery("-1", "", 0)
			So(err, ShouldEqual, ErrInvalidCursor)
		})

		Convey("Defaults to limit 10", func() {
			p, err := NewPageQuery("", "", 0)
			So(err, ShouldBeNil)
			So(p.Limit, ShouldEqual, 10)
		})

		Convey("Maxes to limit 10", func() {
			p, err := NewPageQuery("", "", 0)
			So(err, ShouldBeNil)
			So(p.Limit, ShouldEqual, 10)
		})

		Convey("Errors when limit is less than zero", func() {
			_, err := NewPageQuery("", "", -1)
			So(err, ShouldEqual, ErrInvalidLimit)
		})

		Convey("Errors when limit is greater than 200", func() {
			_, err := NewPageQuery("", "", 200)
			So(err, ShouldBeNil)

			_, err = NewPageQuery("", "", 201)
			So(err, ShouldEqual, ErrInvalidLimit)
		})
	})
}
