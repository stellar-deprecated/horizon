package horizon

import (
	. "github.com/smartystreets/goconvey/convey"
	"testing"
)

func TestAppInit(t *testing.T) {

	Convey("AppInit.Run()", t, func() {
		init := &AppInit{}

		Convey("Panics when a cycle is present", func() {
			init.Add(Initializer{"a", func(app *App) { t.Log("a") }, []string{"b"}})
			init.Add(Initializer{"b", func(app *App) { t.Log("b") }, []string{"c"}})
			init.Add(Initializer{"c", func(app *App) { t.Log("c") }, []string{"a"}})

			So(func() {
				init.Run(&App{})
			}, ShouldPanic)
		})

		Convey("Runs initializers in the right order", func() {
			run := []string{}

			init.Add(Initializer{"a", func(app *App) { run = append(run, "a") }, nil})
			init.Add(Initializer{"b", func(app *App) { run = append(run, "b") }, []string{"a"}})
			init.Add(Initializer{"c", func(app *App) { run = append(run, "c") }, []string{"b"}})
			init.Run(&App{})

			So(run, ShouldResemble, []string{"a", "b", "c"})
		})

		Convey("Does not run initializers more than once", func() {
			run := 0

			init.Add(Initializer{"a", func(app *App) { run++ }, nil})
			init.Add(Initializer{"b", func(app *App) {}, []string{"a"}})
			init.Add(Initializer{"c", func(app *App) {}, []string{"a"}})
			init.Run(&App{})

			So(run, ShouldEqual, 1)
		})
	})
}
