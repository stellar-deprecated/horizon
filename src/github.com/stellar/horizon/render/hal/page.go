package hal

//TODO: rename to Page when we've remove all old Page uses
type NewPage struct {
	Links struct {
		Self Link `json:"self"`
		Next Link `json:"next"`
		Prev Link `json:"prev"`
	} `json:"_links"`

	Embedded struct {
		Records []Pageable `json:"records"`
	} `json:"_embedded"`

	BasePath string `json:"-"`
	Order    string `json:"-"`
	Limit    int32  `json:"-"`
	Cursor   string `json:"-"`
}

func (p *NewPage) Add(rec Pageable) {
	p.Embedded.Records = append(p.Embedded.Records, rec)
}

func (p *NewPage) PopulateLinks() {
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
