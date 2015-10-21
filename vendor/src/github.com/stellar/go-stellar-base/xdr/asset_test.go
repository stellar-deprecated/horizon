package xdr_test

import (
	"github.com/stellar/go-stellar-base"
	. "github.com/stellar/go-stellar-base/xdr"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("xdr.Asset#Extract()", func() {
	var asset Asset

	Context("asset is native", func() {
		BeforeEach(func() {
			var err error
			asset, err = NewAsset(AssetTypeAssetTypeNative, nil)
			Expect(err).To(BeNil())
		})

		It("can extract to AssetType", func() {
			var typ AssetType
			err := asset.Extract(&typ, nil, nil)
			Expect(err).To(BeNil())
			Expect(typ).To(Equal(AssetTypeAssetTypeNative))
		})

		It("can extract to string", func() {
			var typ string
			err := asset.Extract(&typ, nil, nil)
			Expect(err).To(BeNil())
			Expect(typ).To(Equal("native"))
		})
	})

	Context("asset is credit_alphanum4", func() {
		BeforeEach(func() {
			var err error
			an := AssetAlphaNum4{}
			an.Issuer, err = stellarbase.AddressToAccountId("GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H")
			Expect(err).To(BeNil())
			copy(an.AssetCode[:], []byte("USD"))

			asset, err = NewAsset(AssetTypeAssetTypeCreditAlphanum4, an)
			Expect(err).To(BeNil())
		})

		It("can extract when typ is AssetType", func() {
			var typ AssetType
			var code, issuer string

			err := asset.Extract(&typ, &code, &issuer)
			Expect(err).To(BeNil())
			Expect(typ).To(Equal(AssetTypeAssetTypeCreditAlphanum4))
			Expect(code).To(Equal("USD"))
			Expect(issuer).To(Equal("GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"))
		})

		It("can extract to strings", func() {
			var typ, code, issuer string

			err := asset.Extract(&typ, &code, &issuer)
			Expect(err).To(BeNil())
			Expect(typ).To(Equal("credit_alphanum4"))
			Expect(code).To(Equal("USD"))
			Expect(issuer).To(Equal("GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"))
		})

	})
})

var _ = Describe("xdr.Asset#String()", func() {
	var asset Asset

	Context("asset is native", func() {
		BeforeEach(func() {
			var err error
			asset, err = NewAsset(AssetTypeAssetTypeNative, nil)
			Expect(err).To(BeNil())
		})

		It("returns 'native'", func() {
			Expect(asset.String()).To(Equal("native"))
		})
	})

	Context("asset is credit_alphanum4", func() {
		BeforeEach(func() {
			var err error
			an := AssetAlphaNum4{}
			an.Issuer, err = stellarbase.AddressToAccountId("GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H")
			Expect(err).To(BeNil())
			copy(an.AssetCode[:], []byte("USD"))

			asset, err = NewAsset(AssetTypeAssetTypeCreditAlphanum4, an)
			Expect(err).To(BeNil())
		})

		It("returns 'type/code/issuer'", func() {
			Expect(asset.String()).To(Equal("credit_alphanum4/USD/GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"))
		})
	})
})
