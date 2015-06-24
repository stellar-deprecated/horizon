package halgo_test

import (
	"."
	"encoding/json"
	"fmt"
	"net/http"
)

func ExampleLinks() {
	type person struct {
		halgo.Links
		Id   int
		Name string
	}

	p := person{
		Id:   1,
		Name: "James",

		Links: halgo.Links{}.
			Self("http://example.com/users/1").
			Link("invoices", "http://example.com/users/1/invoices"),
	}

	b, _ := json.MarshalIndent(p, "", "  ")

	fmt.Println(string(b))
	// Output:
	// {
	//   "_links": {
	//     "invoices": {
	//       "href": "http://example.com/users/1/invoices"
	//     },
	//     "self": {
	//       "href": "http://example.com/users/1"
	//     }
	//   },
	//   "Id": 1,
	//   "Name": "James"
	// }
}

func ExampleLinks_templated() {
	type root struct{ halgo.Links }

	p := root{
		Links: halgo.Links{}.
			Link("invoices", "http://example.com/invoices{?q,sort}"),
	}

	b, _ := json.MarshalIndent(p, "", "  ")

	fmt.Println(string(b))
	// Output:
	// {
	//   "_links": {
	//     "invoices": {
	//       "href": "http://example.com/invoices{?q,sort}",
	//       "templated": true
	//     }
	//   }
	// }
}

func ExampleLinks_multiple() {
	type person struct {
		halgo.Links
		Id   int
		Name string
	}

	p := person{
		Id:   1,
		Name: "James",

		Links: halgo.Links{}.
			Add("aliases", halgo.Link{Href: "http://example.com/users/4"}, halgo.Link{Href: "http://example.com/users/19"}),
	}

	b, _ := json.MarshalIndent(p, "", "  ")

	fmt.Println(string(b))
	// Output:
	// {
	//   "_links": {
	//     "aliases": [
	//       {
	//         "href": "http://example.com/users/4"
	//       },
	//       {
	//         "href": "http://example.com/users/19"
	//       }
	//     ]
	//   },
	//   "Id": 1,
	//   "Name": "James"
	// }
}

func ExampleNavigator() {
	var me struct{ Username string }

	halgo.Navigator("http://haltalk.herokuapp.com/").
		Followf("ht:me", halgo.P{"name": "jagregory"}).
		Unmarshal(&me)

	fmt.Println(me.Username)
	// Output: jagregory
}

func ExampleNavigator_logging() {
	var me struct{ Username string }

	nav := halgo.Navigator("http://haltalk.herokuapp.com/")
	nav.HttpClient = halgo.LoggingHttpClient{http.DefaultClient}

	nav.Followf("ht:me", halgo.P{"name": "jagregory"}).
		Unmarshal(&me)

	fmt.Printf("Username: %s", me.Username)
	// Output:
	// GET http://haltalk.herokuapp.com/
	// GET http://haltalk.herokuapp.com/users/jagregory
	// Username: jagregory
}
