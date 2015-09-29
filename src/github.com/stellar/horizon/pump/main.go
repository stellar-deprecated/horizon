package pump

type Pump struct {
	trigger chan struct{}
	outputs map[chan struct{}]bool
	adds    chan chan struct{}
	removes chan chan struct{}
}

func NewPump(trigger chan struct{}) *Pump {
	result := &Pump{
		trigger: trigger,
		outputs: map[chan struct{}]bool{},
		adds:    make(chan chan struct{}),
		removes: make(chan chan struct{}),
	}
	go result.run()
	return result
}

func (p *Pump) Subscribe() chan struct{} {
	result := make(chan struct{}, 1)
	p.adds <- result
	return result
}

func (p *Pump) Unsubscribe(l chan struct{}) {
	p.removes <- l
}

func (p *Pump) run() {
	for {
		select {
		case _, more := <-p.trigger:
			if !more {
				for o, _ := range p.outputs {
					close(o)
				}
				return
			}

			for o, _ := range p.outputs {
				trySend(o)
			}
		case ch := <-p.adds:
			p.outputs[ch] = true
		case ch := <-p.removes:
			close(ch)
			delete(p.outputs, ch)
		}
	}
}

// try to trigger the provided channel, but don't bother
// if you can't.
func trySend(o chan struct{}) {
	select {
	case o <- struct{}{}:
		//NOOP
	default:
		//NOOP
	}
}
