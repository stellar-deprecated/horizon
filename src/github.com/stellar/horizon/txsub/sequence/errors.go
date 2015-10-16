package sequence

import (
	"errors"
)

var (
	ErrNoMoreRoom  = errors.New("queue full")
	ErrTimeout     = errors.New("timeout")
	ErrBadSequence = errors.New("bad sequence")
)
