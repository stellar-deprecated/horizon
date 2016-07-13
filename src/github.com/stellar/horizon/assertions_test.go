package horizon

import (
	"bytes"
	"encoding/json"

	"github.com/stretchr/testify/assert"
)

// Assertions provides an assertions helper.  Custom assertions for this package
// can be defined as methods on this struct.
type Assertions struct {
	*assert.Assertions
}

func (a *Assertions) PageOf(length int, body *bytes.Buffer) bool {

	var result map[string]interface{}
	err := json.Unmarshal(body.Bytes(), &result)

	if !a.NoError(err, "failed to parse body") {
		return false
	}

	embedded, ok := result["_embedded"]

	if !a.True(ok, "_embedded not found in response") {
		return false
	}

	records, ok := embedded.(map[string]interface{})["records"]

	if !a.True(ok, "no 'records' property on _embedded object") {
		return false
	}

	return a.Len(records, length)
}
