package db

import (
	"github.com/jinzhu/gorm"
	"github.com/stellar/go-horizon/test"
)

func OpenTestDatabase() (gorm.DB, error) {
	return gorm.Open("postgres", test.DatabaseUrl())
}
