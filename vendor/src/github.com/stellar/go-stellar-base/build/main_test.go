package build

import (
	"fmt"
	"log"

	"github.com/stellar/go-stellar-base"
)

// ExampleTransactionBuilder creates and signs a simple transaction, and then
// encodes it into a hex string capable of being submitted to stellar-core.
//
// It uses the transaction builder system
func ExampleTransactionBuilder() {
	_, spriv, err := stellarbase.GenerateKeyFromSeed("s3Fy8h5LEcYVE8aofthKWHeJpygbntw5HgcekFw93K6XqTW4gEx")

	if err != nil {
		log.Fatal(err)
	}

	tx := Transaction(
		SourceAccount{spriv.Address()},
		Sequence{1},
		Payment(
			Destination{"gLtaC2yiJs3r8YE2bTiVfFs9Mi5KdRoLNLUA45HYVy4iNd7S9p"},
			NativeAmount{50 * 10000000},
		),
	)

	txe := tx.Sign(&spriv)
	txeHex, err := txe.Hex()

	fmt.Printf("tx hex: %s", txeHex)
	// Output: tx hex: 3658fe7598d20c7a6de3297f84bc52bd2a1ec8c0f1f6c5b41cc1c7571b4331f00000000a000000000000000100000000000000000000000100000000000000012d24692ed08bbf679ba199448870d2191e876fecd92fdd9f6d274da4e6de134100000000000000001dcd650000000001dd302d0c0cee527cf02f6a0aec6916966298712914c63e3c57de74a6e27c29ea234a555fcc36533417afe4e1147815a42529fbca3429bc7caf0a06dc6b383ca6e9d4d80f

}
