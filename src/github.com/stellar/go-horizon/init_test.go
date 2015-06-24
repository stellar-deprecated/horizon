package horizon

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
)

func TestAppInit(t *testing.T) {

	Convey("initializerSet.Run()", t, func() {
		init := &initializerSet{}

		Convey("Panics when a cycle is present", func() {
			init.Add("a", func(app *App) { t.Log("a") }, "b")
			init.Add("b", func(app *App) { t.Log("b") }, "c")
			init.Add("c", func(app *App) { t.Log("c") }, "a")

			So(func() {
				init.Run(&App{})
			}, ShouldPanic)
		})

		Convey("Runs initializers in the right order", func() {
			run := []string{}

			init.Add("a", func(app *App) { run = append(run, "a") })
			init.Add("b", func(app *App) { run = append(run, "b") }, "a")
			init.Add("c", func(app *App) { run = append(run, "c") }, "b")
			init.Run(&App{})

			So(run, ShouldResemble, []string{"a", "b", "c"})
		})

		Convey("Does not run initializers more than once", func() {
			run := 0

			init.Add("a", func(app *App) { run++ })
			init.Add("b", func(app *App) {}, "a")
			init.Add("c", func(app *App) {}, "a")
			init.Run(&App{})

			So(run, ShouldEqual, 1)
		})
	})
}
