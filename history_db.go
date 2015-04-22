package horizon

import (
	"github.com/jinzhu/gorm"
	_ "github.com/lib/pq"
)

type HistoryDb struct {
	gdb gorm.DB
}

func NewHistoryDb(app *App) (*HistoryDb, error) {
	result := HistoryDb{}

	db, err := gorm.Open("postgres", app.config.DatabaseUrl)

	if err != nil {
		return nil, err
	}

	result.gdb = db

	err = db.DB().Ping()

	if err != nil {
		return nil, err
	}

	return &result, nil
}
