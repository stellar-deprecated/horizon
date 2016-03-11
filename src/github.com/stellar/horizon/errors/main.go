package errors

import (
	"github.com/go-errors/errors"
)

// Stack returns the stack, as a string, if one can be extracted from `err`.
func Stack(err error) string {

	if stackProvider, ok := err.(*errors.Error); ok {
		return string(stackProvider.Stack())
	}

	return "unknown"
}
