package resource

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
)

func TestAccount(t *testing.T) {
	Convey("Account.GetData", t, func() {
		account := Account{Data: map[string]string{"test": "aGVsbG8="}}

		Convey("Returns decoded value if the key exists", func() {
			decoded := account.GetData("test")
			So(string(decoded), ShouldEqual, "hello")
		})

		Convey("Returns empty slice if key doesn't exist", func() {
			decoded := account.GetData("test2")
			So(len(decoded), ShouldEqual, 0)
		})
	})
}
