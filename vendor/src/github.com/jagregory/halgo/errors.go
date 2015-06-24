package halgo

import "fmt"

// LinkNotFoundError is returned when a link with the specified relation
// couldn't be found in the links collection.
type LinkNotFoundError struct {
	rel   string
	items map[string]linkSet
}

func (err LinkNotFoundError) Error() string {
	opts := []string{}

	for k, _ := range err.items {
		opts = append(opts, fmt.Sprintf("'%s'", k))
	}

	return fmt.Sprintf("Response didn't contain '%s' link relation: available options were %v",
		err.rel, opts)
}

// InvalidUrlError is returned when a link contains a malformed or invalid
// url.
type InvalidUrlError struct {
	url string
}

func (err InvalidUrlError) Error() string {
	return fmt.Sprintf("Invalid URL: %s", err.url)
}
