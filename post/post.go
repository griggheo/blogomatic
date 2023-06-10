package post

import (
	"database/sql"
	"github.com/labstack/echo/v4"
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

	stmt, err := ph.db.Prepare("INSERT INTO posts(title, content) VALUES(?,?)")
	if err != nil {
		return err
	}

	res, err := stmt.Exec(post.Title, post.Content)
	if err != nil {
		return err
	}

	id, err := res.LastInsertId()
	if err != nil {
		return err
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

	stmt, err := ph.db.Prepare("UPDATE posts SET title = ?, content = ? WHERE id = ?")
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

	stmt, err := ph.db.Prepare("DELETE FROM posts WHERE id = ?")
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
