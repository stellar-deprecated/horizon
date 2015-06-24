package stellarbase

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
)

func TestSeeds(t *testing.T) {
	Convey("Given a 32-byte value", t, func() {
		bytes := []byte("masterpassphrasemasterpassphrase")

		Convey("The RawSeed is created with a copy of the data", func() {
			rawSeed, err := NewRawSeed(bytes)
			So(err, ShouldBeNil)
			So(rawSeed[:], ShouldResemble, bytes)
		})
	})

	Convey("Given an empty value", t, func() {
		bytes := []byte{}

		Convey("An error is returned", func() {
			_, err := NewRawSeed(bytes)
			So(err, ShouldNotBeNil)
		})
	})

	Convey("Given an value larger than 32 bytes", t, func() {
		bytes := []byte("masterpassphrasemasterpassphrasemasterpassphrasemasterpassphrase")

		Convey("An error is returned", func() {
			_, err := NewRawSeed(bytes)
			So(err, ShouldNotBeNil)
		})
	})
}

func TestSigning(t *testing.T) {
	Convey("Given the master passphrase", t, func() {
		rawSeed, err := NewRawSeed([]byte("masterpassphrasemasterpassphrase"))
		So(err, ShouldBeNil)

		Convey("and a key pair from the seed", func() {
			pub, priv, err := GenerateKeyFromRawSeed(rawSeed)

			So(err, ShouldBeNil)
			So(len(pub.keyData), ShouldEqual, 32)
			So(len(priv.keyData), ShouldEqual, 64)

			Convey("When signing a message", func() {
				message := []byte("hello world")
				signature := priv.Sign(message)

				Convey("The signature should be verifiable", func() {
					valid := pub.Verify(message, signature)
					So(valid, ShouldBeTrue)
				})
			})
		})
	})
}

func TestGeneration(t *testing.T) {
	Convey("Given a base58 encoded stellar seed", t, func() {
		seed := "s3Fy8h5LEcYVE8aofthKWHeJpygbntw5HgcekFw93K6XqTW4gEx"
		address := "gQANmQ3bQkt6VbPrqGmKHq1EuT2cRkFsftDfEhWqdvJgTiibyu"

		Convey("A key pair can be made from the seed", func() {
			pub, priv, err := GenerateKeyFromSeed(seed)

			So(err, ShouldBeNil)

			Convey("The address associated with the seed is correct", func() {
				So(pub.Address(), ShouldResemble, address)
				So(priv.Address(), ShouldResemble, address)
			})

			Convey("The seed is recoverable", func() {
				So(priv.Seed(), ShouldResemble, seed)
			})
		})
	})
}
