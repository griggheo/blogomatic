package main

import (
	// "io/ioutil"
	//"io"
	"github.com/spf13/viper"
	"github.com/stretchr/testify/assert"
	"os"
	"strings"
	"testing"
)

func TestLoadConfigFileExists(t *testing.T) {
	mockConfig := `
db:
  type: postgres
  host: localhost
  port: 5432
  user: postgres
  password: somepass
  dbname: blogomatic
`

	// Create a strings.Reader with the mock config data
	reader := strings.NewReader(mockConfig)

	// Call the loadConfig function with the mock config reader
	err := loadConfig(reader)

	assert.NoError(t, err)
	// Assert the expected configuration values
	assert.Equal(t, "postgres", viper.GetString("db.type"))
	assert.Equal(t, "localhost", viper.GetString("db.host"))
	assert.Equal(t, 5432, viper.GetInt("db.port"))
	assert.Equal(t, "postgres", viper.GetString("db.user"))
	assert.Equal(t, "somepass", viper.GetString("db.password"))
	assert.Equal(t, "blogomatic", viper.GetString("db.dbname"))
}

func TestLoadConfigFileDoesNotExist(t *testing.T) {
	mockConfig := ""

	// Create a strings.Reader with the mock config data
	reader := strings.NewReader(mockConfig)

	// Call the loadConfig function with the mock config reader
	err := loadConfig(reader)

	assert.NoError(t, err)
	// Assert the expected configuration values
	assert.Equal(t, "sqlite", viper.GetString("db.type"))
	assert.Equal(t, "", viper.GetString("db.host"))
	assert.Equal(t, 0, viper.GetInt("db.port"))
	assert.Equal(t, "", viper.GetString("db.user"))
	assert.Equal(t, "", viper.GetString("db.password"))
	assert.Equal(t, "blogomatic.db", viper.GetString("db.dbname"))
}

func TestLoadConfigEnvVars(t *testing.T) {

	os.Setenv("DB_TYPE", "mysql")
	os.Setenv("DB_USER", "mysql")
	os.Setenv("DB_PORT", "3306")

	mockConfig := `
db:
  type: postgres
  host: localhost
  port: 5432
  user: postgres
  password: somepass
  dbname: blogomatic
`

	// Create a strings.Reader with the mock config data
	reader := strings.NewReader(mockConfig)

	// Call the loadConfig function with the mock config reader
	err := loadConfig(reader)

	assert.NoError(t, err)
	// Assert the expected configuration values
	// Values from ENV vars should override values from config file
	assert.Equal(t, "mysql", viper.GetString("db.type"))
	assert.Equal(t, "localhost", viper.GetString("db.host"))
	assert.Equal(t, 3306, viper.GetInt("db.port"))
	assert.Equal(t, "mysql", viper.GetString("db.user"))
	assert.Equal(t, "somepass", viper.GetString("db.password"))
	assert.Equal(t, "blogomatic", viper.GetString("db.dbname"))
}
