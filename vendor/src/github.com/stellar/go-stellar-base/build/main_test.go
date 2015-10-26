package build

import (
	"fmt"
	"testing"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

func TestBuild(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Package: github.com/stellar/go-stellar-base/build")
}

// ExampleTransactionBuilder creates and signs a simple transaction, and then
// encodes it into a hex string capable of being submitted to stellar-core.
//
// It uses the transaction builder system
func ExampleTransactionBuilder() {
	seed := "SDOTALIMPAM2IV65IOZA7KZL7XWZI5BODFXTRVLIHLQZQCKK57PH5F3H"
	tx := Transaction(
		SourceAccount{seed},
		Sequence{1},
		Payment(
			Destination{"GAWSI2JO2CF36Z43UGMUJCDQ2IMR5B3P5TMS7XM7NUTU3JHG3YJUDQXA"},
			NativeAmount{"50"},
		),
	)

	txe := tx.Sign(seed)
	txeB64, _ := txe.Base64()

	fmt.Printf("tx base64: %s", txeB64)
	// Output: tx base64: AAAAADZY/nWY0gx6beMpf4S8Ur0qHsjA8fbFtBzBx1cbQzHwAAAAZAAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAALSRpLtCLv2eboZlEiHDSGR6Hb+zZL92fbSdNpObeE0EAAAAAAAAAAB3NZQAAAAAAAAAAARtDMfAAAABA2oIeQxoJl53RMRWFeLB865zcky39f2gf2PmUubCuJYccEePRSrTC8QQrMOgGwD8a6oe8dgltvezdDsmmXBPyBw==
}
