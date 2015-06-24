package main

import (
	"net/http"

	"github.com/codegangsta/negroni"
	"github.com/gorilla/mux"
	"github.com/sebest/xff"
)

func main() {
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("hello from " + r.RemoteAddr + "\n"))
	})

	mux := mux.NewRouter()
	mux.Handle("/", handler)

	n := negroni.Classic()
	n.Use(negroni.HandlerFunc(xff.XFF))
	n.UseHandler(mux)
	n.Run(":3000")
}
