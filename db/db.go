package db

import (
	"database/sql"
	_ "github.com/lib/pq"
	_ "github.com/mattn/go-sqlite3"
)

func InitializeDB(dbType, dbConnectionString string) (*sql.DB, error) {
	var db *sql.DB
	var statement *sql.Stmt
	var err error

	switch dbType {
	case "postgres":
		if dbConnectionString == "" {
			dbConnectionString = "user=postgres dbname=blog sslmode=disable" // Default value
		}
		db, err = sql.Open("postgres", dbConnectionString)
		if err != nil {
			return nil, err
		}
		statement, err = db.Prepare(`CREATE TABLE IF NOT EXISTS posts (
			id SERIAL PRIMARY KEY,
			title TEXT,
			content TEXT,
			date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)`)
		if err != nil {
			return nil, err
		}
	default:
		if dbConnectionString == "" {
			dbConnectionString = "./blogomatic.db" // Default value
		}
		db, err = sql.Open("sqlite3", dbConnectionString)
		if err != nil {
			return nil, err
		}
		statement, err = db.Prepare(`CREATE TABLE IF NOT EXISTS posts (
			id INTEGER PRIMARY KEY,
			title TEXT,
			content TEXT,
			date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)`)
		if err != nil {
			return nil, err
		}
	}

	_, err = statement.Exec()
	if err != nil {
		return nil, err
	}

	return db, nil
}
