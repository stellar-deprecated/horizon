package halgo

import (
	"encoding/json"
	"testing"
)

type MyResource struct {
	Links
	Name string
}

var exampleJson string = `{"_links":{"ea:admin":[{"href":"/admins/2","title":"Fred"},{"href":"/admins/5","title":"Kate"}],"ea:find":{"href":"/orders{?id}","templated":true},"next":{"href":"/orders?page=2"},"self":{"href":"/orders"}},"Name":"James"}`

func TestMarshalLinksToJSON(t *testing.T) {
	res := MyResource{
		Name: "James",
		Links: Links{}.
			Self("/orders").
			Next("/orders?page=2").
			Link("ea:find", "/orders{?id}").
			Add("ea:admin", Link{Href: "/admins/2", Title: "Fred"}, Link{Href: "/admins/5", Title: "Kate"}),
	}

	b, err := json.Marshal(res)
	if err != nil {
		t.Fatal(err)
	}

	if string(b) != exampleJson {
		t.Errorf("Unexpected JSON %s", b)
	}
}

func TestEmptyMarshalLinksToJSON(t *testing.T) {
	res := MyResource{
		Name:  "James",
		Links: Links{},
	}

	b, err := json.Marshal(res)
	if err != nil {
		t.Fatal(err)
	}

	if string(b) != `{"Name":"James"}` {
		t.Errorf("Unexpected JSON %s", b)
	}
}

func TestUnmarshalLinksToJSON(t *testing.T) {
	res := MyResource{}
	err := json.Unmarshal([]byte(exampleJson), &res)
	if err != nil {
		t.Fatal(err)
	}

	if res.Name != "James" {
		t.Error("Expected name to be unmarshaled")
	}

	href, err := res.Href("self")
	if err != nil {
		t.Fatal(err)
	}
	if expected := "/orders"; href != expected {
		t.Errorf("Expected self to be %s, got %s", expected, href)
	}

	href, err = res.Href("next")
	if err != nil {
		t.Fatal(err)
	}
	if expected := "/orders?page=2"; href != expected {
		t.Errorf("Expected next to be %s, got %s", expected, href)
	}

	href, err = res.HrefParams("ea:find", P{"id": 123})
	if err != nil {
		t.Fatal(err)
	}
	if expected := "/orders?id=123"; href != expected {
		t.Errorf("Expected ea:find to be %s, got %s", expected, href)
	}

	// TODO: handle multiple here
	href, err = res.Href("ea:admin")
	if err != nil {
		t.Fatal(err)
	}
	if expected := "/admins/2"; href != expected {
		t.Errorf("Expected ea:admin to be %s, got %s", expected, href)
	}
}

func TestLinkFormatting(t *testing.T) {
	l := Links{}.
		Link("no-format", "/a/url/%s").
		Link("format", "/a/url/%d", 10)

	if v, _ := l.Href("no-format"); v != "/a/url/%s" {
		t.Errorf("Expected no-format to match '/a/url/%%s', got %s", v)
	}

	if v, _ := l.Href("format"); v != "/a/url/10" {
		t.Errorf("Expected no-format to match '/a/url/10', got %s", v)
	}
}

func TestAutoSettingOfTemplated(t *testing.T) {
	l := Links{}.
		Link("not-templated", "/a/b/c").
		Link("templated", "/a/b/{c}")

	if l.Items["not-templated"][0].Templated != false {
		t.Error("not-templated should have Templated=false")
	}

	if l.Items["templated"][0].Templated != true {
		t.Error("not-templated should have Templated=true")
	}
}
