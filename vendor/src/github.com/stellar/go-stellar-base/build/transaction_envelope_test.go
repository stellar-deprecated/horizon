package build

import (
	"errors"
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("TransactionEnvelope Mutators:", func() {

	var (
		subject TransactionEnvelopeBuilder
		mut     TransactionEnvelopeMutator
	)

	BeforeEach(func() { subject = TransactionEnvelopeBuilder{} })
	JustBeforeEach(func() { subject.Mutate(mut) })

	Describe("TransactionBuilder", func() {
		Context("that is valid", func() {
			BeforeEach(func() { mut = Transaction(Sequence{10}) })
			It("succeeds", func() { Expect(subject.Err).NotTo(HaveOccurred()) })
			It("sets the TX", func() { Expect(subject.E.Tx.SeqNum).To(BeEquivalentTo(10)) })
		})

		Context("with an error set on it", func() {
			err := errors.New("busted!")
			BeforeEach(func() { mut = &TransactionBuilder{Err: err} })
			It("propagates the error upwards", func() { Expect(subject.Err).To(Equal(err)) })
		})

	})

	Describe("Sign", func() {
		Context("with a valid key", func() {
			BeforeEach(func() {
				subject.MutateTX(SourceAccount{"SDOTALIMPAM2IV65IOZA7KZL7XWZI5BODFXTRVLIHLQZQCKK57PH5F3H"})
				mut = Sign{"SDOTALIMPAM2IV65IOZA7KZL7XWZI5BODFXTRVLIHLQZQCKK57PH5F3H"}
			})

			It("succeeds", func() { Expect(subject.Err).NotTo(HaveOccurred()) })
			It("adds a signature to the envelope", func() {
				Expect(subject.E.Signatures).To(HaveLen(1))
			})
		})

		Context("with an invalid key", func() {
			BeforeEach(func() { mut = Sign{""} })
			It("fails", func() {
				Expect(subject.Err).To(HaveOccurred())
			})
		})
	})

})
