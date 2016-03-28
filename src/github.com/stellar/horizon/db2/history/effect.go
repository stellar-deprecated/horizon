package history

import (
	"encoding/json"
	"fmt"

	"github.com/go-errors/errors"
)

// UnmarshalDetails unmarshals the details of this effect into `dest`
func (r *Effect) UnmarshalDetails(dest interface{}) error {
	if !r.DetailsString.Valid {
		return nil
	}

	err := json.Unmarshal([]byte(r.DetailsString.String), &dest)
	if err != nil {
		err = errors.Wrap(err, 1)
	}

	return err
}

// ID returns a lexically ordered id for this effect record
func (r *Effect) ID() string {
	return fmt.Sprintf("%019d-%010d", r.HistoryOperationID, r.Order)
}

// PagingToken returns a cursor for this effect
func (r *Effect) PagingToken() string {
	return fmt.Sprintf("%d-%d", r.HistoryOperationID, r.Order)
}
