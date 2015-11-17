package xdr_test

import (
	. "github.com/stellar/go-stellar-base/xdr"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/ginkgo/extensions/table"
	. "github.com/onsi/gomega"
)

var _ = Describe("sql.Scanner implementations", func() {

	DescribeTable("AccountFlags",
		func(in interface{}, val AccountFlags, shouldSucceed bool) {
			var scanned AccountFlags
			err := scanned.Scan(in)

			if shouldSucceed {
				Expect(err).To(BeNil())
			} else {
				Expect(err).ToNot(BeNil())
			}

			Expect(scanned).To(Equal(val))
		},
		Entry("zero", int64(0), AccountFlags(0), true),
		Entry("required", int64(1), AccountFlags(1), true),
		Entry("revokable", int64(2), AccountFlags(2), true),
		Entry("immutable", int64(4), AccountFlags(4), true),
		Entry("string", "0", AccountFlags(0), false),
	)

	DescribeTable("AssetType",
		func(in interface{}, val AssetType, shouldSucceed bool) {
			var scanned AssetType
			err := scanned.Scan(in)

			if shouldSucceed {
				Expect(err).To(BeNil())
			} else {
				Expect(err).ToNot(BeNil())
			}

			Expect(scanned).To(Equal(val))
		},
		Entry("native", int64(0), AssetTypeAssetTypeNative, true),
		Entry("credit alphanum4", int64(1), AssetTypeAssetTypeCreditAlphanum4, true),
		Entry("credit alphanum12", int64(2), AssetTypeAssetTypeCreditAlphanum12, true),
		Entry("string", "native", AssetTypeAssetTypeNative, false),
	)

	DescribeTable("Int64",
		func(in interface{}, val Int64, shouldSucceed bool) {
			var scanned Int64
			err := scanned.Scan(in)

			if shouldSucceed {
				Expect(err).To(BeNil())
			} else {
				Expect(err).ToNot(BeNil())
			}

			Expect(scanned).To(Equal(val))
		},
		Entry("pos", int64(1), Int64(1), true),
		Entry("neg", int64(-1), Int64(-1), true),
		Entry("zero", int64(0), Int64(0), true),
		Entry("string", "0", Int64(0), false),
	)

	DescribeTable("Thresholds",
		func(in interface{}, val Thresholds, shouldSucceed bool) {
			var scanned Thresholds
			err := scanned.Scan(in)

			if shouldSucceed {
				Expect(err).To(BeNil())
			} else {
				Expect(err).ToNot(BeNil())
			}

			Expect(scanned).To(Equal(val))
		},
		Entry("default", "AQAAAA==", Thresholds{0x01, 0x00, 0x00, 0x00}, true),
		Entry("non-default", "AgACAg==", Thresholds{0x02, 0x00, 0x02, 0x02}, true),
		Entry("bytes", []byte("AQAAAA=="), Thresholds{0x01, 0x00, 0x00, 0x00}, true),
		Entry("number", 0, Thresholds{}, false),
	)
})
