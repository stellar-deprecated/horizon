# halgo

[HAL](http://stateless.co/hal_specification.html) implementation in Go.

> HAL is a simple format that gives a consistent and easy way to hyperlink between resources in your API.

Halgo helps with generating HAL-compliant JSON from Go structs, and
provides a Navigator for walking a HAL-compliant API.

[![GoDoc](https://godoc.org/github.com/jagregory/halgo?status.png)](https://godoc.org/github.com/jagregory/halgo)

## Install

    go get github.com/jagregory/halgo

## Usage

Serialising a resource with HAL links:

```go
import "github.com/jagregory/halgo"

type MyResource struct {
  halgo.Links
  Name string
}

res := MyResource{
  Links: Links{}.
    Self("/orders").
    Next("/orders?page=2").
    Link("ea:find", "/orders{?id}").
    Add("ea:admin", Link{Href: "/admins/2", Title: "Fred"}, Link{Href: "/admins/5", Title: "Kate"}),
  Name: "James",
}

bytes, _ := json.Marshal(res)

fmt.Println(bytes)

// {
//   "_links": {
//     "self": { "href": "/orders" },
//     "next": { "href": "/orders?page=2" },
//     "ea:find": { "href": "/orders{?id}", "templated": true },
//     "ea:admin": [{
//         "href": "/admins/2",
//         "title": "Fred"
//     }, {
//         "href": "/admins/5",
//         "title": "Kate"
//     }]
//   },
//   "Name": "James"
// }
```

Navigating a HAL-compliant API:

```go
res, err := halgo.Navigator("http://example.com").
  Follow("products").
  Followf("page", halgo.P{"n": 10}).
  Get()
```

Deserialising a resource: 

```go
import "github.com/jagregory/halgo"

type MyResource struct {
  halgo.Links
  Name string
}

data := []byte(`{
  "_links": {
    "self": { "href": "/orders" },
    "next": { "href": "/orders?page=2" },
    "ea:find": { "href": "/orders{?id}", "templated": true },
    "ea:admin": [{
        "href": "/admins/2",
        "title": "Fred"
    }, {
        "href": "/admins/5",
        "title": "Kate"
    }]
  },
  "Name": "James"
}`)

res := MyResource{}
json.Unmarshal(data, &res)

res.Name // "James"
res.Links.Href("self") // "/orders"
res.Links.HrefParams("self", Params{"id": 123}) // "/orders?id=123"
```

## TODO

* Curies
* Embedded resources
