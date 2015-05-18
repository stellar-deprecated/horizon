package horizon

import (
	"github.com/stellar/go-horizon/log"
	"golang.org/x/net/context"
)

type InitFn func(*App)

type Initializer struct {
	Name string
	Fn   InitFn
	Deps []string
}

type AppInit struct {
	Initializers []Initializer
}

// Add adds a new initializer into the chain
func (init *AppInit) Add(i Initializer) {
	init.Initializers = append(init.Initializers, i)
}

// Run initializes the provided application, but running every Initializer
func (init *AppInit) Run(app *App) {
	alreadyRun := make(map[string]bool)

	for {
		ranInitializer := false
		for _, i := range init.Initializers {
			runnable := true

			// if we've already been run, skip
			if _, ok := alreadyRun[i.Name]; ok {
				runnable = false
			}

			// if any of our dependencies haven't been run, skip
			for _, d := range i.Deps {
				if _, ok := alreadyRun[d]; !ok {
					runnable = false
					break
				}
			}

			if !runnable {
				continue
			}

			log.Debugf(context.Background(), "running init:%s", i.Name)
			i.Fn(app)
			alreadyRun[i.Name] = true
			ranInitializer = true
			log.Debugf(context.Background(), "ran init:%s", i.Name)
		}
		// If, after a full loop through the initializers we ran nothing
		// we are done
		if !ranInitializer {
			break
		}
	}

	// if we didn't get to run all initializers, we have a cycle
	if len(alreadyRun) != len(init.Initializers) {
		log.Panicln(context.Background(), "initializer cycle detected")
	}
}
