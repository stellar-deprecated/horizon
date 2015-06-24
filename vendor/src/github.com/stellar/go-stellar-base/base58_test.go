package stellarbase

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
)

func TestBase58(t *testing.T) {
	Convey("Given a message", t, func() {
		unencoded := []byte("hello world")
		encoded := "StVgDLaUATiyKyV"
		accountIdEncoded := "gpvQBfBaMiGQZ2xUqW9KNR"
		seedEncoded := "n3GdokGwy1qJ11qLmsTzoL"

		Convey("When encoding the message", func() {
			actual := EncodeBase58(unencoded)

			Convey("The encoded should be correct", func() {
				So(actual, ShouldEqual, encoded)
			})
		})

		Convey("When encoding the message as VersionByteAccountID", func() {
			actual := EncodeBase58Check(VersionByteAccountID, unencoded)

			Convey("The encoded should be correct", func() {
				So(actual, ShouldEqual, accountIdEncoded)
			})
		})

		Convey("When encoding the message as VersionByteSeed", func() {
			actual := EncodeBase58Check(VersionByteSeed, unencoded)

			Convey("The encoded should be correct", func() {
				So(actual, ShouldEqual, seedEncoded)
			})
		})

		Convey("When decoding the base58 encoded form", func() {
			actual, err := DecodeBase58(encoded)
			So(err, ShouldBeNil)

			Convey("The decoding should be correct", func() {
				So(actual, ShouldResemble, unencoded)
			})
		})

		Convey("When decoding the base58check AccountID encoded form", func() {
			actual, err := DecodeBase58Check(VersionByteAccountID, accountIdEncoded)
			So(err, ShouldBeNil)

			Convey("The decoding should be correct", func() {
				So(actual, ShouldResemble, unencoded)
			})
		})

		Convey("When decoding the base58check Seed encoded form", func() {
			actual, err := DecodeBase58Check(VersionByteSeed, seedEncoded)
			So(err, ShouldBeNil)

			Convey("The decoding should be correct", func() {
				So(actual, ShouldResemble, unencoded)
			})
		})

		Convey("When decoding as the wrong base58check encoded form", func() {
			_, err := DecodeBase58Check(VersionByteAccountID, seedEncoded)

			Convey("The returned error is correct", func() {
				So(err, ShouldNotBeNil)
				ivbErr, ok := err.(ErrInvalidVersionByte)
				So(ok, ShouldBeTrue)
				So(ivbErr.Actual, ShouldEqual, VersionByteSeed)
				So(ivbErr.Expected, ShouldEqual, VersionByteAccountID)
			})
		})

	})

	Convey("Bad Input", t, func() {
		_, err := DecodeBase58Check(VersionByteAccountID, "")
		So(err, ShouldEqual, ErrNotCheckEncoded)

	})

}
