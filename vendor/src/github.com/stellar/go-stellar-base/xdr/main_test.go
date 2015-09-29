package xdr_test

import (
	. "github.com/stellar/go-stellar-base/xdr"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("xdr.SafeUnmarshal", func() {
	var (
		result int32
		data   []byte
		err    error
	)

	JustBeforeEach(func() {
		err = SafeUnmarshal(data, &result)
	})

	Context("input data is a single xdr value", func() {
		BeforeEach(func() {
			data = []byte{0x00, 0x00, 0x00, 0x01}
		})

		It("succeeds", func() {
			Expect(err).To(BeNil())
		})

		It("decodes the data correctly", func() {
			Expect(result).To(Equal(int32(1)))
		})
	})

	Context("when the input data contains more than one encoded struct", func() {
		BeforeEach(func() {
			data = []byte{
				0x00, 0x00, 0x00, 0x01,
				0x00, 0x00, 0x00, 0x01,
			}
		})
		It("errors", func() {
			Expect(err).ToNot(BeNil())
		})
	})
})

var _ = Describe("xdr.SafeUnmarshalBase64", func() {
	var (
		result int32
		data   string
		err    error
	)

	JustBeforeEach(func() {
		err = SafeUnmarshalBase64(data, &result)
	})

	Context("input data is a single xdr value", func() {
		BeforeEach(func() {
			data = "AAAAAQ=="
		})

		It("succeeds", func() {
			Expect(err).To(BeNil())
		})

		It("decodes the data correctly", func() {
			Expect(result).To(Equal(int32(1)))
		})
	})

	Context("when the input data contains more than one encoded struct", func() {
		BeforeEach(func() {
			data = "AAAAAQAAAAI="
		})
		It("errors", func() {
			Expect(err).ToNot(BeNil())
		})
	})
})
