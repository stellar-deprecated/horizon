package db

import (
	"github.com/rcrowley/go-metrics"
	"golang.org/x/net/context"
)

type streamManagerCommand struct {
	fn   func()
	done chan<- bool
}

type listenerMap map[StreamedQuery]*streamedQueryListener

type streamManager struct {
	cmds       chan streamManagerCommand
	queries    map[Query]listenerMap
	queryGauge metrics.Gauge
}

func newStreamManager() *streamManager {
	return &streamManager{
		cmds:       make(chan streamManagerCommand, 10),
		queries:    make(map[Query]listenerMap),
		queryGauge: metrics.NewGauge(),
	}
}

func (sm *streamManager) Pump() {
	sm.Do(func() {
		sm.sampleQueryCount()
		for q, l := range sm.queries {
			sm.pumpQuery(q, l)
		}
		sm.sampleQueryCount()
	})
}

func (sm *streamManager) PumpOne(q Query) {
	sm.Do(func() {
		l, ok := sm.queries[q]

		if !ok {
			// if this query isn't already registered with the query manager
			return
		}

		sm.pumpQuery(q, l)
		sm.sampleQueryCount()
	})
}

// WARNING: only call this within an `sm.Do(func(){})` block, otherwise we will
// race with other pumps.
func (sm *streamManager) pumpQuery(q Query, l listenerMap) {
	results, err := q.Get()

	if err != nil {
		// TODO: log an error
		sm.removeQuery(q)
		return
	}

	for sq, listener := range l {
		ok := listener.Deliver(results)

		if !ok || q.IsComplete(listener.sentCount) {
			sm.removeListener(q, sq)
		}

	}
}

func (sm *streamManager) removeQuery(q Query) {
	listeners := sm.queries[q]

	for sq, _ := range listeners {
		sm.removeListener(q, sq)
	}
}

func (sm *streamManager) removeListener(q Query, sq StreamedQuery) {
	listener := sm.queries[q][sq]
	listener.Close()
	delete(sm.queries[q], sq)

	if len(sm.queries[q]) == 0 {
		delete(sm.queries, q)
	}
}

func (sm *streamManager) Run() {
	for cmd := range sm.cmds {
		cmd.fn()
		cmd.done <- true
		close(cmd.done)
	}
}

func (sm *streamManager) Shutdown() {
	close(sm.cmds)
}

func (sm *streamManager) Do(fn func()) {
	done := make(chan bool, 1)
	cmd := streamManagerCommand{fn, done}
	sm.cmds <- cmd
	<-done
}

func (sm *streamManager) Add(ctx context.Context, q Query) StreamedQuery {
	toClient := make(chan StreamRecord)
	fromManager := make(chan StreamRecord)

	result := &streamedQuery{
		records: toClient,
	}

	newListener := &streamedQueryListener{
		ctx:     ctx,
		send:    toClient,
		receive: fromManager,
	}

	sm.Do(func() {
		listeners, ok := sm.queries[q]

		if !ok {
			listeners = make(listenerMap)
			sm.queries[q] = listeners
		}

		go newListener.Run()
		sm.queries[q][result] = newListener

		sm.sampleQueryCount()
	})

	return result
}

func (sm *streamManager) sampleQueryCount() {
	var queryCount int64
	for _, l := range sm.queries {
		queryCount += int64(len(l))
	}

	sm.queryGauge.Update(queryCount)
}
