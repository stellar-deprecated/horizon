package db

import (
	"golang.org/x/net/context"
	"time"
)

func init() {
	go globalStreamManager.Run()
	return
}

var globalStreamManager *streamManager = newStreamManager()

type StreamedQuery interface {
	Get() <-chan StreamRecord
	Cancel()
}

type StreamRecord struct {
	Record interface{}
	Err    error
}

func AutoPump() {
	go func() {
		for {
			<-time.After(1 * time.Second)
			PumpStreamer()
		}
	}()
}

func Stream(ctx context.Context, query Query) StreamedQuery {
	return globalStreamManager.Add(ctx, query)
}

func CancelStream(q StreamedQuery) {
	q.Cancel()
}

// Triggers an execution cycle of any in-progress streaming queries
func PumpStreamer() {
	globalStreamManager.Pump()
}

type streamedQuery struct {
	records <-chan StreamRecord
}

func (s *streamedQuery) Get() <-chan StreamRecord {
	return s.records
}

func (s *streamedQuery) Cancel() {

}

type streamedQueryListener struct {
	ctx       context.Context
	sentCount int
	send      chan<- StreamRecord
	receive   chan StreamRecord
}

func (sl *streamedQueryListener) Run() {
	defer close(sl.send)

	for {
		select {
		case record, ok := <-sl.receive:
			if !ok {
				return
			}
			sl.send <- record
		case <-sl.ctx.Done():
			return
		}
	}
}

func (sl *streamedQueryListener) Deliver(results []interface{}) {
	toSend := results[sl.sentCount:len(results)]
	for _, r := range toSend {
		sl.receive <- StreamRecord{Record: r}
		sl.sentCount++
	}
}

func (sl *streamedQueryListener) Close() {
	close(sl.receive)
}
