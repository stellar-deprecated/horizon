package friendbot

import (
	"errors"
	. "github.com/stellar/go-stellar-base/build"
	"github.com/stellar/go-stellar-base/keypair"
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/txsub"
	"golang.org/x/net/context"
	"sync"
)

type Bot struct {
	Submitter *txsub.System
	Secret    string
	Network   string

	sequence uint64
	lock     sync.Mutex
}

func (bot *Bot) Pay(ctx context.Context, address string) (result txsub.Result) {

	// establish initial sequence if needed
	if bot.sequence == 0 {
		result.Err = bot.refreshSequence(ctx)
		if result.Err != nil {
			return
		}
	}

	var envelope string
	envelope, result.Err = bot.makeTx(address)
	if result.Err != nil {
		return
	}

	resultChan := bot.Submitter.Submit(ctx, envelope)

	select {
	case result := <-resultChan:
		return result
	case <-ctx.Done():
		return txsub.Result{Err: txsub.ErrCanceled}
	}
}

func (bot *Bot) makeTx(address string) (string, error) {
	bot.lock.Lock()
	bot.lock.Unlock()

	tx := Transaction(
		SourceAccount{bot.Secret},
		Sequence{xdr.SequenceNumber(bot.sequence + 1)},
		CreateAccount(
			Destination{address},
			NativeAmount{"10000.00"},
			Network{bot.Network},
		),
	)

	bot.sequence++

	txe := tx.Sign(bot.Secret)

	return txe.Base64()
}

func (bot *Bot) refreshSequence(ctx context.Context) error {
	bot.lock.Lock()
	bot.lock.Unlock()

	addy := bot.address()
	sp := bot.Submitter.Sequences

	seqs, err := sp.Get(ctx, []string{addy})
	if err != nil {
		return err
	}

	seq, ok := seqs[addy]
	if !ok {
		return errors.New("friendbot account not found")
	}

	bot.sequence = seq
	return nil
}

func (bot *Bot) address() string {
	kp := keypair.MustParse(bot.Secret)
	return kp.Address()
}
