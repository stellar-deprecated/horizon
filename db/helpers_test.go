package db

import (
	"github.com/jinzhu/gorm"
	"os"
)

const (
	DefaultTestDatabaseUrl = "postgres://localhost:5432/horizon_test?sslmode=disable"
)

func OpenTestDatabase() (gorm.DB, error) {
	return gorm.Open("postgres", GetTestDatabaseUrl())
}

func GetTestDatabaseUrl() string {
	databaseUrl := os.Getenv("DATABASE_URL")

	if databaseUrl == "" {
		databaseUrl = DefaultTestDatabaseUrl
	}

	return databaseUrl
}
