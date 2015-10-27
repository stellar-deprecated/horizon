// stellar-sign is a small interactive utility to help you contribute a
// signature to a transaction envelope.
//
// It prompts you for a key
package main

import (
	"bufio"
	"fmt"
	"github.com/howeyc/gopass"
	"github.com/stellar/go-stellar-base/build"
	"github.com/stellar/go-stellar-base/xdr"
	"log"
	"os"
	"strings"
)

var in *bufio.Reader

func main() {
	in = bufio.NewReader(os.Stdin)

	// read envelope
	env, err := readLine("Enter envelope (base64): ", false)
	if err != nil {
		log.Fatal(err)
	}

	// parse the envelope
	var txe xdr.TransactionEnvelope
	err = xdr.SafeUnmarshalBase64(env, &txe)
	if err != nil {
		log.Fatal(err)
	}

	// TODO: print transaction details

	// read seed
	seed, err := readLine("Enter seed: ", true)
	if err != nil {
		log.Fatal(err)
	}

	// sign the transaction
	b := &build.TransactionEnvelopeBuilder{E: &txe}
	b.Init()
	b.MutateTX(build.PublicNetwork)
	b.Mutate(build.Sign{seed})
	if b.Err != nil {
		log.Fatal(b.Err)
	}

	newEnv, err := xdr.MarshalBase64(b.E)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Print("\n==== Result ====\n\n")
	fmt.Println(newEnv)

}

func readLine(prompt string, private bool) (string, error) {
	fmt.Fprintf(os.Stdout, prompt)
	var line string
	var err error

	if private {
		line = string(gopass.GetPasswdMasked())
	} else {
		line, err = in.ReadString('\n')
		if err != nil {
			return "", err
		}
	}
	return strings.Trim(line, "\n"), nil
}
