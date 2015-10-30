package sse

import (
	"sync"
)

var pump <-chan struct{}
var lock sync.Mutex
var nextTick chan struct{}

// SetPump established the pump that will be used to drive streaming responses.
// Everytime the provided channel sends any open connections will be triggered
// to run their queries again and delivery any new results to clients.
func SetPump(p <-chan struct{}) {
	if p == nil {
		panic("cannot set a null pump")
	}

	lock.Lock()
	defer lock.Unlock()

	nextTick = make(chan struct{})

	if pump != nil {
		panic("cannot set sse pump twice")
	}

	pump = p

	go run()
}

// Pumped returns a channel that will be closed the next time the input pump
// sends.  It can be used similar to `ctx.Done()`, like so:  `<-sse.Pumped()`
func Pumped() <-chan struct{} {
	return nextTick
}

// run is the workhorse of the stream pump system.  It facilitates the triggering
// of open streams by closing a new channel every time the input pump sends.
func run() {
	for {
		_, more := <-pump

		prev := nextTick
		nextTick = make(chan struct{})
		// trigger all listeners by closing the nextTick channel
		close(prev)

		if !more {
			return
		}
	}
}
