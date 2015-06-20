package sse

import (
	"sync"
	"time"

	"golang.org/x/net/context"
)

// AutoPump triggers every second. Added when --auto-pump is enabled,
// this is useful if you're not running the ledger importer but want to test
// the streaming response system.
var AutoPump = time.NewTicker(1 * time.Second).C

var pump <-chan time.Time
var lock sync.Mutex
var ctx context.Context
var nextTick chan struct{}

// SetPump established the pump that will be used to drive streaming responses.
// Everytime the provided channel sends any open connections will be triggered
// to run their queries again and delivery any new results to clients.
func SetPump(c context.Context, p <-chan time.Time) {
	if p == nil {
		panic("cannot set a null pump")
	}

	lock.Lock()
	defer lock.Unlock()

	ctx = c
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
		select {
		case _, more := <-pump:
			prev := nextTick
			nextTick = make(chan struct{})
			// trigger all listeners by closing the nextTick channel
			close(prev)

			if !more {
				return
			}
		case <-ctx.Done():
			pump = nil
			return
		}
	}
}
