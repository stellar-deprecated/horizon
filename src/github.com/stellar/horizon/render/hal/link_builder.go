package hal

import (
	"fmt"
	"net/url"
	"strings"
)

// StandardPagingOptions is a helper string to make creating paged collection
// URIs simpler.
const StandardPagingOptions = "{?cursor,limit,order}"

type LinkBuilder struct {
	Base *url.URL
}

func (lb *LinkBuilder) Link(parts ...string) Link {
	path := strings.Join(parts, "/")

	var href string
	if lb.Base != nil {
		pu, err := url.Parse(path)
		if err != nil {
			panic(err)
		}
		href = lb.Base.ResolveReference(pu).String()
	} else {
		href = path
	}

	return NewLink(href)
}

func (lb *LinkBuilder) PagedLink(parts ...string) Link {
	nl := lb.Link(parts...)
	nl.Href += StandardPagingOptions
	nl.PopulateTemplated()
	return nl
}

func (lb *LinkBuilder) Linkf(format string, args ...interface{}) Link {
	return lb.Link(fmt.Sprintf(format, args...))
}
