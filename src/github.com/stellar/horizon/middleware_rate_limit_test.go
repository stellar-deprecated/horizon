package horizon

import (
	"fmt"
	"testing"

	"github.com/stellar/horizon/test"
)

func TestRateLimitMiddleware(t *testing.T) {
	ht := StartHTTPTest(t, "base")
	defer ht.Finish()

	w := ht.Get("/")
	remaining := TestRateLimit - 1
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.Equal(
			fmt.Sprintf("%d", TestRateLimit),
			w.Header().Get("X-RateLimit-Limit"),
		)
		ht.Assert.Equal(
			fmt.Sprintf("%d", remaining),
			w.Header().Get("X-RateLimit-Remaining"),
		)
		ht.Assert.Equal(
			fmt.Sprintf("%d", 3599),
			w.Header().Get("X-RateLimit-Reset"),
		)
	}

	for remaining > 0 {
		w := ht.Get("/")
		remaining--

		if ht.Assert.Equal(200, w.Code) {
			ht.Assert.Equal(
				fmt.Sprintf("%d", remaining),
				w.Header().Get("X-RateLimit-Remaining"),
			)
		}
	}

	w = ht.Get("/")
	ht.Assert.Equal(429, w.Code)

	// rate limits are managed per IP
	w = ht.Get("/", test.RequestHelperRemoteAddr("127.0.0.2"))
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.Equal(
			fmt.Sprintf("%d", TestRateLimit-1),
			w.Header().Get("X-RateLimit-Remaining"),
		)
	}

	// ports get ignored
	w = ht.Get("/", test.RequestHelperRemoteAddr("127.0.0.2:123"))
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.Equal(
			fmt.Sprintf("%d", TestRateLimit-2),
			w.Header().Get("X-RateLimit-Remaining"),
		)
	}

	// XFF
	w = ht.Get(
		"/",
		test.RequestHelperRemoteAddr("127.0.0.1:123"),
		test.RequestHelperXFF("4.4.4.4"),
	)
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.Equal(
			fmt.Sprintf("%d", TestRateLimit-1),
			w.Header().Get("X-RateLimit-Remaining"),
		)
	}

	// ignore private ips
	w = ht.Get(
		"/",
		test.RequestHelperRemoteAddr("127.0.0.1:123"),
		test.RequestHelperXFF("10.0.0.1, 4.4.4.4"),
	)
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.Equal(
			fmt.Sprintf("%d", TestRateLimit-2),
			w.Header().Get("X-RateLimit-Remaining"),
		)
	}

	// ignore trailing ips
	w = ht.Get(
		"/",
		test.RequestHelperRemoteAddr("127.0.0.1:123"),
		test.RequestHelperXFF("4.4.4.4, 4.4.4.5, 127.0.0.1"),
	)
	if ht.Assert.Equal(200, w.Code) {
		ht.Assert.Equal(
			fmt.Sprintf("%d", TestRateLimit-3),
			w.Header().Get("X-RateLimit-Remaining"),
		)
	}
}
