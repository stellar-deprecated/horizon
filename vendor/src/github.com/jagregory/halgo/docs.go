// Package halgo is used to create application/hal+json representations of
// Go structs, and provides a client for navigating HAL-compliant APIs.
//
// There are two sides to halgo: serialisation and navigation.
//
// Serialisation is based around the Links struct, which you can embed in
// your own structures to provide HAL compliant links when you serialise
// your structs into JSON. Links has a little builder API which can make
// it somewhat more succinct to generate these links than modelling the
// structures yourself.
//
// Navigation, specifically through the Navigator func, is for when you
// want to consume a HAL-compliant API and walk its relations.
package halgo
