package post

import (
	"database/sql"
	"fmt"
	"github.com/labstack/echo/v4"
	"log"
	"net/http"
)

type Post struct {
	ID      int    `json:"id"`
	Title   string `json:"title"`
	Content string `json:"content"`
	Date    string `json:"date"`
}

type DBInterface interface {
	Prepare(query string) (*sql.Stmt, error)
	Exec(query string, args ...interface{}) (sql.Result, error)
	Query(query string, args ...interface{}) (*sql.Rows, error)
	QueryRow(query string, args ...interface{}) *sql.Row
	Close() error
}

type PostHandler struct {
	//db *sql.DB
	db DBInterface
}

// func NewPostHandler(db *sql.DB) *PostHandler {
// 	return &PostHandler{
// 		db: db,
// 	}
// }

func NewPostHandler(db DBInterface) *PostHandler {
	return &PostHandler{
		db: db,
	}
}

func (ph *PostHandler) CreatePost(c echo.Context) error {
	post := Post{}
	if err := c.Bind(&post); err != nil {
		return err
	}

	var res sql.Result
	var err error

	// Handle PostgreSQL
	if _, ok := ph.db.(*sql.DB); ok {
		res, err = ph.db.Exec("INSERT INTO posts(title, content) VALUES($1, $2) RETURNING id", post.Title, post.Content)
	} else {
		// Handle SQLite
		res, err = ph.db.Exec("INSERT INTO posts(title, content) VALUES(?, ?)", post.Title, post.Content)
	}

	if err != nil {
		return err
	}

	// Retrieve the last inserted ID based on the database driver
	var id int64
	if _, ok := ph.db.(*sql.DB); ok {
		id, _ = res.LastInsertId()
	} else {
		id, _ = res.RowsAffected()
	}

	post.ID = int(id)
	return c.JSON(http.StatusCreated, post)
}

func (ph *PostHandler) EditPost(c echo.Context) error {
	id := c.Param("id")

	post := Post{}
	if err := c.Bind(&post); err != nil {
		return err
	}

//	stmt, err := ph.db.Prepare("UPDATE posts SET title = ?, content = ? WHERE id = ?")
//	if err != nil {
//		return err
//	}

	stmt, err := ph.db.Prepare("UPDATE posts SET title = $1, content = $2 WHERE id = $3")
	if err != nil {
	    return err
	}

	_, err = stmt.Exec(post.Title, post.Content, id)
	if err != nil {
		return err
	}

	return c.NoContent(http.StatusOK)
}

func (ph *PostHandler) DeletePost(c echo.Context) error {
	id := c.Param("id")

    	log.Println("Deleting post with ID:", id)
	fmt.Printf("Type of id: %T\n", id)

//	stmt, err := ph.db.Prepare("DELETE FROM posts WHERE id = ?")
//	if err != nil {
//		return err
//	}

	stmt, err := ph.db.Prepare("DELETE FROM posts WHERE id = $1")
	if err != nil {
	    return err
	}

	_, err = stmt.Exec(id)
	if err != nil {
		return err
	}

	return c.NoContent(http.StatusOK)
}

func (ph *PostHandler) GetPosts(c echo.Context) error {
	rows, err := ph.db.Query("SELECT id, title, content, date FROM posts ORDER BY date DESC")
	if err != nil {
		return err
	}
	defer rows.Close()

	posts := []Post{}
	for rows.Next() {
		post := Post{}
		err := rows.Scan(&post.ID, &post.Title, &post.Content, &post.Date)
		if err != nil {
			return err
		}
		posts = append(posts, post)
	}

	return c.JSON(http.StatusOK, posts)
}
