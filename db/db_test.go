package db

import (
	//"database/sql"
	"time"
	"testing"

	_ "github.com/mattn/go-sqlite3"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestInitializeSqliteDB(t *testing.T) {
	// Call the InitializeDB function
	database, err := InitializeDB("", ":memory:")
	require.NoError(t, err)

	// Delay for a short period to allow table creation to finish
	time.Sleep(100 * time.Millisecond)

	// Query the database to check if the posts table exists
	row := database.QueryRow("SELECT name FROM sqlite_schema WHERE type='table' AND name='posts'")
	var tableName string
	err = row.Scan(&tableName)
	require.NoError(t, err)
	assert.Equal(t, "posts", tableName)
}

