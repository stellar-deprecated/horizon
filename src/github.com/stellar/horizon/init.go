package horizon

import (
	"github.com/stellar/horizon/log"
	"golang.org/x/net/context"
)

// InitFn is a function that contributes to the initialization of an App struct
type InitFn func(*App)

type initializer struct {
	Name string
	Fn   InitFn
	Deps []string
}

type initializerSet []initializer

var appInit initializerSet

// Add adds a new initializer into the chain
func (is *initializerSet) Add(name string, fn InitFn, deps ...string) {
	*is = append(*is, initializer{
		Name: name,
		Fn:   fn,
		Deps: deps,
	})
}

// Run initializes the provided application, but running every Initializer
func (is *initializerSet) Run(app *App) {
	init := *is
	alreadyRun := make(map[string]bool)

	for {
		ranInitializer := false
		for _, i := range init {
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
	if len(alreadyRun) != len(init) {
		log.Panicln(context.Background(), "initializer cycle detected")
	}
}
