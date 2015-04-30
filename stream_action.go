package horizon

import (
	"github.com/stellar/go-horizon/render/sse"
	"github.com/zenazn/goji/web"
	"golang.org/x/net/context"
	"net/http"
	"time"
)

type streamTemp struct {
	Message string
	ID      string
}

func (s streamTemp) Err() error {
	return nil
}

func (s streamTemp) SseData() interface{} {
	return s.Message
}

func (s streamTemp) SseId() string {
	return s.ID
}

func streamAction(c web.C, w http.ResponseWriter, r *http.Request) {
	chn := make(chan sse.Event, 5)
	go func() {
		time.Sleep(1 * time.Second)
		chn <- streamTemp{"hello", "1"}
		time.Sleep(1 * time.Second)
		chn <- streamTemp{"world", "2"}
		time.Sleep(1 * time.Second)
		chn <- streamTemp{"from", "3"}
		time.Sleep(1 * time.Second)
		chn <- streamTemp{"go", "whoa"}

		close(chn)
	}()

	streamer := &sse.Streamer{context.Background(), chn}
	streamer.ServeHTTP(w, r)

}
