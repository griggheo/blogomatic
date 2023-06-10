package post

import (
	"github.com/DATA-DOG/go-sqlmock"
	"github.com/labstack/echo/v4"
	"github.com/stretchr/testify/assert"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestCreatePost(t *testing.T) {
	// Create a new instance of the SQL mock
	db, mock, err := sqlmock.New(sqlmock.QueryMatcherOption(sqlmock.QueryMatcherEqual))
	if err != nil {
		t.Fatalf("Failed to create SQL mock: %v", err)
	}
	defer db.Close()

	// Create a new instance of the PostHandler with the mock DB
	ph := NewPostHandler(db)

	// Create a new echo context for testing
	e := echo.New()

	// Set up the request
	req := httptest.NewRequest(http.MethodPost, "/posts", strings.NewReader(`{"title":"Test Title", "content":"Test Content"}`))
	req.Header.Set("Content-Type", "application/json")
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	// Set up the expected SQL mock behavior
	mock.ExpectPrepare(`INSERT INTO posts(title, content) VALUES(?,?)`).
	ExpectExec().
	WithArgs("Test Title", "Test Content").
	WillReturnResult(sqlmock.NewResult(1, 1))


	// Call the CreatePost method
	err = ph.CreatePost(c)

	// Assert that there is no error and the response status code is http.StatusCreated
	assert.NoError(t, err)
	assert.Equal(t, http.StatusCreated, rec.Code)

	// Assert that all the expectations were met
	err = mock.ExpectationsWereMet()
	assert.NoError(t, err)
}

func TestEditPost(t *testing.T) {
	// Create a new instance of the SQL mock
	db, mock, err := sqlmock.New(sqlmock.QueryMatcherOption(sqlmock.QueryMatcherEqual))
	if err != nil {
		t.Fatalf("Failed to create SQL mock: %v", err)
	}
	defer db.Close()

	// Create a new instance of the PostHandler with the mock DB
	ph := NewPostHandler(db)

	// Create a new echo context for testing
	e := echo.New()

	// Set up the request
	req := httptest.NewRequest(http.MethodPut, "/posts/1", strings.NewReader(`{"title":"Updated Title", "content":"Updated Content"}`))
	req.Header.Set("Content-Type", "application/json")
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	c.SetPath("/posts/:id")
	c.SetParamNames("id")
	c.SetParamValues("1")

	// Set up the expected SQL mock behavior
	mock.ExpectPrepare("UPDATE posts SET title = ?, content = ? WHERE id = ?").
		ExpectExec().
		WithArgs("Updated Title", "Updated Content", "1").
		WillReturnResult(sqlmock.NewResult(1, 1))

	// Call the EditPost method
	err = ph.EditPost(c)

	// Assert that there is no error and the response status code is http.StatusOK
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, rec.Code)

	// Assert that all the expectations were met
	err = mock.ExpectationsWereMet()
	assert.NoError(t, err)
}

func TestDeletePost(t *testing.T) {
	// Create a new instance of the SQL mock
	db, mock, err := sqlmock.New(sqlmock.QueryMatcherOption(sqlmock.QueryMatcherEqual))
	if err != nil {
		t.Fatalf("Failed to create SQL mock: %v", err)
	}
	defer db.Close()

	// Create a new instance of the PostHandler with the mock DB
	ph := NewPostHandler(db)

	// Create a new echo context for testing
	e := echo.New()

	// Set up the request
	req := httptest.NewRequest(http.MethodDelete, "/posts/1", nil)
	req.Header.Set("Content-Type", "application/json")
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	c.SetPath("/posts/:id")
	c.SetParamNames("id")
	c.SetParamValues("1")

	// Set up the expected SQL mock behavior
	mock.ExpectPrepare("DELETE FROM posts WHERE id = ?").
		ExpectExec().
		WithArgs("1").
		WillReturnResult(sqlmock.NewResult(1, 1))

	// Call the DeletePost method
	err = ph.DeletePost(c)

	// Assert that there is no error and the response status code is http.StatusOK
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, rec.Code)

	// Assert that all the expectations were met
	err = mock.ExpectationsWereMet()
	assert.NoError(t, err)
}
