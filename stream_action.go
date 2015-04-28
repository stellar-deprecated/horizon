package horizon

import (
	"github.com/stellar/go-horizon/rendering/sse"
	"github.com/zenazn/goji/web"
	"golang.org/x/net/context"
	"net/http"
	"time"
)

type streamTemp struct {
	Message string
	ID      string
}

func (s streamTemp) Data() interface{} {
	return s.Message
}

func (s streamTemp) Id() *string {
	return &s.ID
}

func (s streamTemp) Event() *string {
	return nil
}

func streamAction(c web.C, w http.ResponseWriter, r *http.Request) {
	chn := make(chan interface{}, 5)
	go func() {
		time.Sleep(1 * time.Second)
		chn <- streamTemp{"hello", "4"}
		time.Sleep(1 * time.Second)
		chn <- "world"
		time.Sleep(1 * time.Second)
		chn <- "from"
		time.Sleep(1 * time.Second)
		chn <- streamTemp{"hello", "whoa"}

		close(chn)
	}()

	streamer := &sse.Streamer{context.Background(), chn}
	streamer.ServeHTTP(w, r)

}
