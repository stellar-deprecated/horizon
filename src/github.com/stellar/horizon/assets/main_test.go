package assets

import (
	"testing"

	"github.com/go-errors/errors"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/stellar/go-stellar-base/xdr"
)

func TestAssets(t *testing.T) {
	Convey("Parse", t, func() {
		var (
			result xdr.AssetType
			err    error
		)

		result, err = Parse("native")
		So(result, ShouldEqual, xdr.AssetTypeAssetTypeNative)
		So(err, ShouldBeNil)

		result, err = Parse("credit_alphanum4")
		So(result, ShouldEqual, xdr.AssetTypeAssetTypeCreditAlphanum4)
		So(err, ShouldBeNil)

		result, err = Parse("credit_alphanum12")
		So(result, ShouldEqual, xdr.AssetTypeAssetTypeCreditAlphanum12)
		So(err, ShouldBeNil)

		result, err = Parse("not_real")
		So(errors.Is(err, ErrInvalidString), ShouldBeTrue)

		result, err = Parse("")
		So(errors.Is(err, ErrInvalidString), ShouldBeTrue)
	})

	Convey("String", t, func() {
		var (
			result string
			err    error
		)

		result, err = String(xdr.AssetTypeAssetTypeNative)
		So(result, ShouldEqual, "native")
		So(err, ShouldBeNil)

		result, err = String(xdr.AssetTypeAssetTypeCreditAlphanum4)
		So(result, ShouldEqual, "credit_alphanum4")
		So(err, ShouldBeNil)

		result, err = String(xdr.AssetTypeAssetTypeCreditAlphanum12)
		So(result, ShouldEqual, "credit_alphanum12")
		So(err, ShouldBeNil)

		result, err = String(xdr.AssetType(15))
		So(errors.Is(err, ErrInvalidValue), ShouldBeTrue)
	})
}
