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
	_, spriv, err := stellarbase.GenerateKeyFromSeed("SDOTALIMPAM2IV65IOZA7KZL7XWZI5BODFXTRVLIHLQZQCKK57PH5F3H")

	if err != nil {
		log.Fatal(err)
	}

	tx := Transaction(
		SourceAccount{spriv.Address()},
		Sequence{1},
		Payment(
			Destination{"GAWSI2JO2CF36Z43UGMUJCDQ2IMR5B3P5TMS7XM7NUTU3JHG3YJUDQXA"},
			NativeAmount{50 * 10000000},
		),
	)

	txe := tx.Sign(&spriv)
	txeB64, err := txe.Base64()

	fmt.Printf("tx base64: %s", txeB64)
	// Output: tx base64: AAAAADZY/nWY0gx6beMpf4S8Ur0qHsjA8fbFtBzBx1cbQzHwAAAACgAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAALSRpLtCLv2eboZlEiHDSGR6Hb+zZL92fbSdNpObeE0EAAAAAAAAAAB3NZQAAAAAAAAAAARtDMfAAAABAlIJbsNKCRGqsF4uCMRptM2Zd8CQjJwpi9Tou+Hi2IoGH7RPTMPueh9fGltb8isRd6K6SZohT3xvmtcswPazmBQ==
}
