package main

import (
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/codepraxis-io/blogomatic/post"
	"github.com/codepraxis-io/blogomatic/db"
	"net/http"
	"embed"
	"log"
	"os"
	"path"
)

//go:embed web/blog/build/*
var distFS embed.FS

func main() {
	dbType := os.Getenv("DB_TYPE")
	dbConnectionString := os.Getenv("DB_CONNECTION_STRING")

	db, err := db.InitializeDB(dbType, dbConnectionString)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	e := echo.New()
	e.Use(middleware.Logger())

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

