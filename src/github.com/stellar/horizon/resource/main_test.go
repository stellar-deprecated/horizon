package resource

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
)

func TestAccount(t *testing.T) {
	account := Account{
		Data: map[string]string{
			"test":    "aGVsbG8=",
			"invalid": "a_*&^*",
		},
	}

	Convey("Account.GetData", t, func() {
		Convey("Returns decoded value if the key exists", func() {
			decoded, err := account.GetData("test")
			So(err, ShouldBeNil)
			So(string(decoded), ShouldEqual, "hello")
		})

		Convey("Returns empty slice if key doesn't exist", func() {
			decoded, err := account.GetData("test2")
			So(err, ShouldBeNil)
			So(len(decoded), ShouldEqual, 0)
		})

		Convey("Returns error slice if value is invalid", func() {
			_, err := account.GetData("invalid")
			So(err, ShouldNotBeNil)
		})
	})

	Convey("Account.MustGetData", t, func() {
		Convey("Returns decoded value if the key exists", func() {
			decoded := account.MustGetData("test")
			So(string(decoded), ShouldEqual, "hello")
		})

		Convey("Returns empty slice if key doesn't exist", func() {
			decoded := account.MustGetData("test2")
			So(len(decoded), ShouldEqual, 0)
		})

		Convey("Returns error slice if value is invalid", func() {
			So(func() { account.MustGetData("invalid") }, ShouldPanic)
		})
	})
}
