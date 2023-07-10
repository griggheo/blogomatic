package main

import (
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/spf13/viper"
	"github.com/codepraxis-io/blogomatic/post"
	"github.com/codepraxis-io/blogomatic/db"
	"context"
	"embed"
	"fmt"
	"io"
	"net/http"
	"log"
	"os"
	"path"

	"go.opentelemetry.io/contrib/instrumentation/github.com/labstack/echo/otelecho"
	"go.opentelemetry.io/otel/trace"
	"github.com/uptrace/opentelemetry-go-extra/otelplay"
)


func loadConfig(reader io.Reader) error {
	// Set default values for the configuration variables
	viper.SetDefault("db.type", "sqlite")
	viper.SetDefault("db.dbname", "blogomatic.db")

    // // Set the name of the configuration file (without the extension)
    // viper.SetConfigName("config")
    // // Set the path to look for the configuration file
    // viper.AddConfigPath(".")

    // Enable viper to read environment variables
    viper.BindEnv("db.type", "DB_TYPE")
	viper.BindEnv("db.host", "DB_HOST")
	viper.BindEnv("db.port", "DB_PORT")
	viper.BindEnv("db.user", "DB_USER")
	viper.BindEnv("db.password", "DB_PASSWORD")
	viper.BindEnv("db.dbname", "DB_NAME")

	// Set the configuration reader
	viper.SetConfigType("yaml")
	err := viper.ReadConfig(reader)
	if err != nil {
		// Handle errors when reading the configuration
		if _, ok := err.(viper.ConfigParseError); ok {
			// Configuration parse error
			return err
		}
		// Other error occurred, handle it accordingly
		log.Println("Configuration file not found, using default values")
	}

    // // Read the configuration file
    // if err := viper.ReadInConfig(); err != nil {
    //     // Handle errors when reading the configuration file
    //     if _, ok := err.(viper.ConfigFileNotFoundError); ok {
    //         // Configuration file not found
    //         log.Println("Configuration file not found, using default values")
    //     } else {
    //         // Other error occurred, handle it accordingly
    //         panic(fmt.Errorf("failed to read configuration file: %w", err))
    //     }
    // }
	return nil
}

//go:embed web/blog/build/*
var distFS embed.FS
func main() {

	ctx := context.Background()
	shutdown := otelplay.ConfigureOpentelemetry(ctx)
	defer shutdown()

    //loadConfig()

	file, err := os.Open("config.yaml")
	if err != nil {
		log.Println("Configuration file not found, using default values")
	}
	defer file.Close()
	
	// Load the config from the file or use defaults
	if err := loadConfig(file); err != nil {
		log.Fatal(err)
	}

    dbType := viper.GetString("db.type")
	dbName := viper.GetString("db.dbname")

	dbConnectionString := ""
	if dbType == "postgres" {
		dbConnectionString = fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s",
			viper.GetString("db.host"),
			viper.GetInt("db.port"),
			viper.GetString("db.user"),
			viper.GetString("db.password"),
			viper.GetString("db.dbname"),
		)
	} else if dbType == "sqlite" {
		dbConnectionString = dbName
	} else {
		log.Fatalf("Unknown db.type: %s. Must be either sqlite or postgres.", dbType)
	}

	fmt.Printf("dbConnectionString: %s\n", dbConnectionString)

    db, err := db.InitializeDB(dbType, dbConnectionString)
    if err != nil {
        log.Fatal(err)
    }
    defer db.Close()

    e := echo.New()
    e.Use(middleware.Logger())
	e.Use(otelecho.Middleware("blogomatic"))
	e.Use(middleware.Recover())
	e.HTTPErrorHandler = func(err error, c echo.Context) {
		ctx := c.Request().Context()
		trace.SpanFromContext(ctx).RecordError(err)

		e.DefaultHTTPErrorHandler(err, c)
	}

    postHandler := post.NewPostHandler(db)

    e.POST("/posts", postHandler.CreatePost)
    e.PUT("/posts/:id", postHandler.EditPost)
    e.DELETE("/posts/:id", postHandler.DeletePost)
    e.GET("/posts", postHandler.GetPosts)

    e.GET("/*", func(c echo.Context) error {
        file := c.Param("*")
        if file == "" {
            file = "index.html"
        }

        data, err := distFS.ReadFile("web/blog/build/" + file)
        if err != nil {
            return echo.NotFoundHandler(c)
        }

        contentType := http.DetectContentType(data)
        switch path.Ext(file) {
        case ".js":
            contentType = "application/javascript"
        case ".css":
            contentType = "text/css"
        }

        return c.Blob(http.StatusOK, contentType, data)
    })

    e.Start(":8080")
}
