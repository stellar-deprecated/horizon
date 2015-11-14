package hal

// BasePage represents the simplest page: one with no links and only embedded records.
// Can be used to build custom page-like resources
type BasePage struct {
	Embedded struct {
		Records []Pageable `json:"records"`
	} `json:"_embedded"`
}

func (p *BasePage) Add(rec Pageable) {
	p.Embedded.Records = append(p.Embedded.Records, rec)
}

func (p *BasePage) Init() {
	if p.Embedded.Records == nil {
		p.Embedded.Records = make([]Pageable, 0, 1)
	}
}

//TODO: rename to Page when we've remove all old Page uses
type NewPage struct {
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

func (p *NewPage) PopulateLinks() {
	p.Init()

	fmts := p.BasePath + "?order=%s&limit=%d&cursor=%s"
	lb := LinkBuilder{}

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

func (p *NewPage) InvertedOrder() string {
	switch p.Order {
	case "asc":
		return "desc"
	case "desc":
		return "asc"
	default:
		return "asc"
	}
}
