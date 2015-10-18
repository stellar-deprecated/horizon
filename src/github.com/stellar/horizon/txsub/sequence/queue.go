package sequence

import (
	"github.com/oleiade/lane"
	"time"
)

// Queue manages the submission queue for a single source account.  It queues transactions
// for submission when it can detect that a given transaction is guaranteed to produce a tx_BAD_SEQ
// error.
//
// Queue maintains a priority queue of pending submissions, and when updated (via the Update() method)
// with the current sequence number of the account being managed, queued submissions that can be acted upon
// will be unblocked.
//
//
type Queue struct {
	lastActiveAt time.Time
	timeout      time.Duration
	nextSequence uint64
	queue        *lane.PQueue
}

// NewQueue creates a new *Queue
func NewQueue() *Queue {
	return &Queue{
		lastActiveAt: time.Now(),
		timeout:      1 * time.Minute,
		queue:        lane.NewPQueue(lane.MINPQ),
	}
}

// Size returns the count of currently buffered submissions in the queue.
func (q *Queue) Size() int {
	return q.queue.Size()
}

// Push registers a channel on the queue, to be triggered when the sequence
// number provided is crossed.  Push does not perform any triggering (which
// occurs in Update(), even if the current sequence number for this queue is
// the same as the provided sequence, to keep internal complexity much lower.
// Given that, the recommended usage pattern is:
//
// 1. Push the submission onto the queue
// 2. Load the current sequence number for the source account from the DB
// 3. Call Update() with the result from step 2 to trigger the submission if
//		possible
func (q *Queue) Push(sequence uint64) <-chan error {
	ch := make(chan error, 1)
	q.queue.Push(ch, int(sequence))
	return ch
}

// Update notifies the queue that the provided sequence number is the latest
// seen value for the account that this queue manages submissions for.
//
// This function is monotonic... calling it with a sequence number lower than
// the latest seen sequence number is a noop.
func (q *Queue) Update(sequence uint64) {
	if q.nextSequence <= sequence {
		q.nextSequence = sequence + 1
	}

	wasChanged := false

	for {
		if q.Size() == 0 {
			break
		}

		ch, hseq := q.head()
		// if the next queued transaction has a sequence higher than the account's
		// current sequence, stop removing entries
		if hseq > q.nextSequence {
			break
		}

		// since this entry is unlocked (i.e. it's sequence is the next available or in the past
		// we can remove it an mark the queue as changed
		q.queue.Pop()
		wasChanged = true

		if hseq < q.nextSequence {
			ch <- ErrBadSequence
			close(ch)
		} else if hseq == q.nextSequence {
			ch <- nil
			close(ch)

		}
	}

	// if we modified the queue, bump the timeout for this queue
	if wasChanged {
		q.lastActiveAt = time.Now()
		return
	}

	// if the queue wasn't changed, see if it is too old, clear
	// it and make room for other's
	if time.Since(q.lastActiveAt) > q.timeout {
		ch, _ := q.pop()
		for ch != nil {
			ch <- ErrTimeout
			close(ch)
			ch, _ = q.pop()
		}
	}
}

// helper function for interacting with the priority queue
func (q *Queue) head() (chan error, uint64) {
	v, s := q.queue.Head()
	if v == nil {
		return nil, uint64(s)
	}

	return v.(chan error), uint64(s)
}

// helper function for interacting with the priority queue
func (q *Queue) pop() (chan error, uint64) {
	v, s := q.queue.Pop()
	if v == nil {
		return nil, uint64(s)
	}

	return v.(chan error), uint64(s)
}
