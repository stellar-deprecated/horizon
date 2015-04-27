package db

import (
	_ "github.com/lib/pq"
	. "github.com/smartystreets/goconvey/convey"
	"testing"
)

func TestMain(t *testing.T) {

	Convey("db.Results", t, func() {
		query := &mockQuery{2}

		results, err := Results(query)

		So(err, ShouldBeNil)
		So(len(results), ShouldEqual, 2)
	})

	Convey("db.First", t, func() {
		Convey("returns the first record", func() {
			query := &mockQuery{2}
			output, err := First(query)
			So(err, ShouldBeNil)
			So(output.(mockResult), ShouldResemble, mockResult{0})
		})

		Convey("Missing records returns nil", func() {
			query := &mockQuery{0}
			output, err := First(query)
			So(err, ShouldBeNil)
			So(output, ShouldBeNil)
		})
	})
}

type mockQuery struct {
	resultCount int
}

type mockResult struct {
	index int
}

func (q *mockQuery) Get() ([]interface{}, error) {
	results := make([]interface{}, q.resultCount)

	for i := 0; i < q.resultCount; i++ {
		results[i] = mockResult{i}
	}

	return results, nil
}
