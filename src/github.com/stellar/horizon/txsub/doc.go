// Package txsub provides the machinery that horizon uses to submit transactions to
// the stellar network and track their progress.  It also helps to hide some of the
// complex asynchronous nature of transaction submission, waiting to respond to
// submitters when no definitive state is known.
package txsub
