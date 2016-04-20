package schema

import (
	"database/sql"
	"errors"

	migrate "github.com/rubenv/sql-migrate"
	"github.com/stellar/horizon/db2"
)

//go:generate go-bindata -ignore .+\.go$ -pkg schema -o bindata.go ./...

// MigrateDir represents a direction in which to perform schema migrations.
type MigrateDir string

const (
	// MigrateUp causes migrations to be run in the "up" direction.
	MigrateUp MigrateDir = "up"
	// MigrateDown causes migrations to be run in the "down" direction.
	MigrateDown MigrateDir = "down"
	// MigrateRedo causes migrations to be run down, then up
	MigrateRedo MigrateDir = "redo"
)

// Migrations represents all of the schema migration for horizon
var Migrations migrate.MigrationSource = &migrate.AssetMigrationSource{
	Asset:    Asset,
	AssetDir: AssetDir,
	Dir:      "migrations",
}

// Init installs the latest schema into db after clearing it first
func Init(db *db2.Repo) error {
	return db.ExecAll(string(MustAsset("latest.sql")))
}

// Migrate performs schema migration.  Migrations can occur in one of three
// ways:
//
// - up: migrations are performed from the currently installed version upwards.
// If count is 0, all unapplied migrations will be run.
//
// - down: migrations are performed from the current version downard. If count
// is 0, all applied migrations will be run in a downard direction.
//
// - redo: migrations are first ran downard `count` times, and then are rand
// upward back to the current version at the start of the process. If count is
// 0, a count of 1 will be assumed.
func Migrate(db *sql.DB, dir MigrateDir, count int) (int, error) {
	switch dir {
	case MigrateUp:
		return migrate.ExecMax(db, "postgres", Migrations, migrate.Up, count)
	case MigrateDown:
		return migrate.ExecMax(db, "postgres", Migrations, migrate.Down, count)
	case MigrateRedo:

		if count == 0 {
			count = 1
		}

		down, err := migrate.ExecMax(db, "postgres", Migrations, migrate.Down, count)
		if err != nil {
			return down, err
		}

		return migrate.ExecMax(db, "postgres", Migrations, migrate.Up, down)
	default:
		return 0, errors.New("Invalid migration direction")
	}
}
