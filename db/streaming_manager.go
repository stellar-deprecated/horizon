package db

import (
	"golang.org/x/net/context"
)

type streamManagerCommand struct {
	fn   func()
	done chan<- bool
}

type listenerMap map[StreamedQuery]*streamedQueryListener

type streamManager struct {
	cmds    chan streamManagerCommand
	queries map[Query]listenerMap
}

func newStreamManager() *streamManager {
	return &streamManager{
		cmds:    make(chan streamManagerCommand),
		queries: make(map[Query]listenerMap),
	}
}

func (sm *streamManager) Pump() {
	sm.Do(func() {
		for query, listeners := range sm.queries {
			results, err := query.Get()

			if err != nil {
				// TODO: log an error
				sm.removeQuery(query)
				return
			}

			for sq, listener := range listeners {
				ok := listener.Deliver(results)

				if !ok || query.IsComplete(listener.sentCount) {
					sm.removeListener(query, sq)
				}

			}
		}

	})
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
	})

	return result
}
