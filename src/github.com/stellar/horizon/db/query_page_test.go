package db

import (
	"math"
	"testing"

	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/horizon/test"
)

func TestPageQuery(t *testing.T) {
	Convey("NewPageQuery", t, func() {
		var p PageQuery

		Convey("Sets attributes correctly", func() {
			p = MustPageQuery("10", "desc", 15)
			So(p.Cursor, ShouldEqual, "10")
			So(p.Order, ShouldEqual, "desc")
			So(p.Limit, ShouldEqual, 15)
		})

		Convey("Defaults to ordered asc", func() {
			p = MustPageQuery("", "", 0)
			So(p.Order, ShouldEqual, "asc")
		})

		Convey("Errors when order is not 'asc' ord 'desc'", func() {
			_, err := NewPageQuery("", "foo", 0)
			So(err, test.ShouldBeErr, ErrInvalidOrder)
		})

		Convey("CursorInt64", func() {
			Convey("Defaults to 0 when ordered asc", func() {
				p = MustPageQuery("", "asc", 0)
				cursor, err := p.CursorInt64()
				So(err, ShouldBeNil)
				So(cursor, ShouldEqual, 0)
			})

			Convey("Defaults to MaxInt64 when ordered desc", func() {
				p = MustPageQuery("", "desc", 0)
				cursor, err := p.CursorInt64()
				So(err, ShouldBeNil)
				So(cursor, ShouldEqual, 9223372036854775807)
			})

			Convey("Errors when cursor is not parseable as a number", func() {
				p = MustPageQuery("not_a_number", "", 0)
				_, err := p.CursorInt64()
				So(err, test.ShouldBeErr, ErrInvalidCursor)
			})

			Convey("Errors when cursor is less than zero", func() {
				p = MustPageQuery("-1", "", 0)
				_, err := p.CursorInt64()
				So(err, test.ShouldBeErr, ErrInvalidCursor)
			})
		})

		Convey("CursorInt64Pair", func() {
			Convey("Parses the numbers correctly", func() {
				p = MustPageQuery("1231-4456", "asc", 0)
				l, r, err := p.CursorInt64Pair("-")
				So(err, ShouldBeNil)
				So(l, ShouldEqual, 1231)
				So(r, ShouldEqual, 4456)
			})

			Convey("Defaults to 0,0 when ordered asc", func() {
				p = MustPageQuery("", "asc", 0)
				l, r, err := p.CursorInt64Pair("-")
				So(err, ShouldBeNil)
				So(l, ShouldEqual, 0)
				So(r, ShouldEqual, 0)
			})

			Convey("Defaults to MaxInt64, MaxInt64 when ordered desc", func() {
				p = MustPageQuery("", "desc", 0)
				l, r, err := p.CursorInt64Pair("-")
				So(err, ShouldBeNil)
				So(l, ShouldEqual, math.MaxInt64)
				So(r, ShouldEqual, math.MaxInt64)
			})

			Convey("Errors when cursor has no instance of the separator in it", func() {
				p = MustPageQuery("nosep", "", 0)
				_, _, err := p.CursorInt64Pair("-")
				So(err, test.ShouldBeErr, ErrInvalidCursor)
			})

			Convey("Errors when cursor has an unparselable number contained within", func() {
				p = MustPageQuery("123-foo", "", 0)
				_, _, err := p.CursorInt64Pair("-")
				So(err, ShouldNotBeNil)

				p = MustPageQuery("foo-123", "", 0)
				_, _, err = p.CursorInt64Pair("-")
				So(err, ShouldNotBeNil)
			})

			Convey("Errors when cursor has a number that is less than zero", func() {
				p = MustPageQuery("-1:123", "", 0)
				_, _, err := p.CursorInt64Pair(":")
				So(err, test.ShouldBeErr, ErrInvalidCursor)

				p = MustPageQuery("111:-123", "", 0)
				_, _, err = p.CursorInt64Pair(":")
				So(err, test.ShouldBeErr, ErrInvalidCursor)
			})
		})

		Convey("Defaults to limit 10", func() {
			p = MustPageQuery("", "", 0)
			So(p.Limit, ShouldEqual, 10)
		})

		Convey("Maxes to limit 10", func() {
			p = MustPageQuery("", "", 0)
			So(p.Limit, ShouldEqual, 10)
		})

		Convey("Errors when limit is less than zero", func() {
			_, err := NewPageQuery("", "", -1)
			So(err, test.ShouldBeErr, ErrInvalidLimit)
		})

		Convey("Errors when limit is greater than 200", func() {
			_, err := NewPageQuery("", "", 200)
			So(err, ShouldBeNil)

			_, err = NewPageQuery("", "", 201)
			So(err, test.ShouldBeErr, ErrInvalidLimit)
		})
	})
}
