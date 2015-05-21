package sse

import (
	"errors"
	"net/http/httptest"
	"testing"

	. "github.com/smartystreets/goconvey/convey"
)

func TestSsePackage(t *testing.T) {
	Convey("sse.WriteEvent outputs data properly", t, func() {
		expectations := []struct {
			Event     Event
			Substring string
		}{
			{Event{Data: "test"}, "data: \"test\"\n\n"},
			{Event{ID: "1", Data: "test"}, "id: 1\n"},
			{Event{Retry: 1000, Data: "test"}, "retry: 1000\n"},
			{Event{Error: errors.New("busted")}, "event: err\ndata: busted\n\n"},
			{Event{Event: "test", Data: "test"}, "event: test\ndata: \"test\"\n\n"},
		}

		for _, e := range expectations {
			w := httptest.NewRecorder()
			WriteEvent(w, e.Event)
			So(w.Body.String(), ShouldContainSubstring, e.Substring)
		}
	})
}
