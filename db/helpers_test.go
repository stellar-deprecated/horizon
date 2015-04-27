package db

import (
	"github.com/jinzhu/gorm"
	"github.com/stellar/go-horizon/test"
	"log"
)

func OpenTestDatabase() gorm.DB {

	result, err := gorm.Open("postgres", test.DatabaseUrl())

	if err != nil {
		log.Panic(err)
	}
	result.LogMode(true)
	return result
}
