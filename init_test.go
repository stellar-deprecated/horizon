package horizon

import (
	"testing"

	"github.com/stellar/horizon/pkg/test"
)

func TestAppInit(t *testing.T) {
	tt := test.Start(t)
	defer tt.Finish()

	// panics when a cycle is present
	init := &initializerSet{}
	init.Add("a", func(app *App) { t.Log("a") }, "b")
	init.Add("b", func(app *App) { t.Log("b") }, "c")
	init.Add("c", func(app *App) { t.Log("c") }, "a")
	tt.Assert.Panics(func() { init.Run(&App{}) })

	// runs in the right order
	init = &initializerSet{}
	order := []string{}
	init.Add("a", func(app *App) { order = append(order, "a") })
	init.Add("b", func(app *App) { order = append(order, "b") }, "a")
	init.Add("c", func(app *App) { order = append(order, "c") }, "b")

	init.Run(&App{})
	tt.Assert.Equal([]string{"a", "b", "c"}, order)

	// only runs an initializer once
	init = &initializerSet{}
	count := 0
	init.Add("a", func(app *App) { count++ })
	init.Add("b", func(app *App) {}, "a")
	init.Add("c", func(app *App) {}, "a")

	init.Run(&App{})
	tt.Assert.Equal(1, count)

}
