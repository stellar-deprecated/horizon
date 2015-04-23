package horizon

import (
	"github.com/jinzhu/gorm"
	_ "github.com/lib/pq"
)

func NewHistoryDb(app *App) (gorm.DB, error) {
	db, err := gorm.Open("postgres", app.config.DatabaseUrl)

	if err != nil {
		return db, err
	}

	err = db.DB().Ping()

	if err != nil {
		return db, err
	}

	return db, nil
}
