// Package xdr contains the generated code for parsing the xdr structures used
// for stellar.
package xdr

import (
	"bytes"
	"encoding/base64"
	"fmt"
	"strings"
)

// SafeUnmarshalBase64 first decodes the provided reader from base64 before decoding the xdr
// into the provided destination.  Also ensures that the reader is fully consumed.
func SafeUnmarshalBase64(data string, dest interface{}) error {
	b64 := strings.NewReader(data)
	raw := base64.NewDecoder(base64.StdEncoding, b64)
	_, err := Unmarshal(raw, dest)

	if err != nil {
		return err
	}

	if b64.Len() != 0 {
		read := b64.Size() - int64(b64.Len())
		return fmt.Errorf("input not fully consumed. expected to read: %d, actual: %d", b64.Size(), read)
	}

	return nil
}

// SafeUnmarshal decodes the provided reader into the destination and verifies
// that provided bytes are all consumed by the unmarshalling process.
func SafeUnmarshal(data []byte, dest interface{}) error {
	r := bytes.NewReader(data)
	n, err := Unmarshal(r, dest)

	if err != nil {
		return err
	}

	if n != len(data) {
		return fmt.Errorf("input not fully consumed. expected to read: %d, actual: %d", len(data), n)
	}

	return nil
}
