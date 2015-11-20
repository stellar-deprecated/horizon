package hal

import (
	"net/url"
)

// BasePage represents the simplest page: one with no links and only embedded records.
// Can be used to build custom page-like resources
type BasePage struct {
	BaseURL  *url.URL `json:"-"`
	Embedded struct {
		Records []Pageable `json:"records"`
	} `json:"_embedded"`
}

// Add appends the provided record onto the page
func (p *BasePage) Add(rec Pageable) {
	p.Embedded.Records = append(p.Embedded.Records, rec)
}

// Init initialized the Records slice.  This ensures that an empty page
// renders its records as an empty array, rather than `null`
func (p *BasePage) Init() {
	if p.Embedded.Records == nil {
		p.Embedded.Records = make([]Pageable, 0, 1)
	}
}

// Page represents the common page configuration (i.e. has self, next, and prev
// links) and has a helper method `PopulateLinks` to automate their
// initialization.
type Page struct {
	Links struct {
		Self Link `json:"self"`
		Next Link `json:"next"`
		Prev Link `json:"prev"`
	} `json:"_links"`

	BasePage
	BasePath string `json:"-"`
	Order    string `json:"-"`
	Limit    int32  `json:"-"`
	Cursor   string `json:"-"`
}

// PopulateLinks sets the common links for a page.
func (p *Page) PopulateLinks() {
	p.Init()
	fmts := p.BasePath + "?order=%s&limit=%d&cursor=%s"
	lb := LinkBuilder{p.BaseURL}

	p.Links.Self = lb.Linkf(fmts, p.Order, p.Limit, p.Cursor)
	rec := p.Embedded.Records

	if len(rec) > 0 {
		p.Links.Next = lb.Linkf(fmts, p.Order, p.Limit, rec[len(rec)-1].PagingToken())
		p.Links.Prev = lb.Linkf(fmts, p.InvertedOrder(), p.Limit, rec[0].PagingToken())
	} else {
		p.Links.Next = lb.Linkf(fmts, p.Order, p.Limit, p.Cursor)
		p.Links.Prev = lb.Linkf(fmts, p.InvertedOrder(), p.Limit, p.Cursor)
	}
}

// InvertedOrder returns the inversion of the page's current order. Used to
// populate the prev link
func (p *Page) InvertedOrder() string {
	switch p.Order {
	case "asc":
		return "desc"
	case "desc":
		return "asc"
	default:
		return "asc"
	}
}
