package rendering

import (
	"github.com/stellar/go-horizon/db"
	"github.com/stellar/go-horizon/hal"
	"net/http"
)

type Transform func(interface{}) interface{}

func Collection(w http.ResponseWriter, r *http.Request, q db.Query, t Transform) {
	// TODO: negotiate, see if we should stream

	records, err := db.Results(q)
	if err != nil {
		panic(err)
	}

	resources := make([]interface{}, len(records))
	for i, record := range records {
		resources[i] = t(record)
	}

	page := hal.Page{
		Records: resources,
	}

	hal.RenderPage(w, page)
}
