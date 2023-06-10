package post

import (
	"database/sql"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/labstack/echo/v4"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// type DBInterface interface {
// 	Prepare(query string) (*sql.Stmt, error)
// 	Exec(query string, args ...interface{}) (sql.Result, error)
// 	Query(query string, args ...interface{}) (*sql.Rows, error)
// 	QueryRow(query string, args ...interface{}) *sql.Row
// 	Close() error
// }

type MockDB struct {
	mock.Mock
}

func (m *MockDB) Prepare(query string) (*sql.Stmt, error) {
	args := m.Called(query)
	return args.Get(0).(*sql.Stmt), args.Error(1)
}

func (m *MockDB) Exec(query string, args ...interface{}) (sql.Result, error) {
	arguments := make([]interface{}, len(args))
	for i, arg := range args {
		arguments[i] = mock.AnythingOfType(arg.(string))
	}
	result := m.Called(append([]interface{}{query}, arguments...)...)
	return result.Get(0).(sql.Result), result.Error(1)
}

func (m *MockDB) Query(query string, args ...interface{}) (*sql.Rows, error) {
	arguments := make([]interface{}, len(args))
	for i, arg := range args {
		arguments[i] = mock.AnythingOfType(arg.(string))
	}
	rows := m.Called(append([]interface{}{query}, arguments...)...)
	return rows.Get(0).(*sql.Rows), rows.Error(1)
}

func (m *MockDB) QueryRow(query string, args ...interface{}) *sql.Row {
	arguments := make([]interface{}, len(args))
	for i, arg := range args {
		arguments[i] = mock.AnythingOfType(arg.(string))
	}
	row := m.Called(append([]interface{}{query}, arguments...)...)
	return row.Get(0).(*sql.Row)
}

func (m *MockDB) Close() error {
	args := m.Called()
	return args.Error(0)
}

type MockStmt struct {
	mock.Mock
}

func (m *MockStmt) Exec(args ...interface{}) (sql.Result, error) {
	arguments := make([]interface{}, len(args))
	for i, arg := range args {
		arguments[i] = mock.AnythingOfType(arg.(string))
	}
	result := m.Called(arguments...)
	return result.Get(0).(sql.Result), result.Error(1)
}

func (m *MockStmt) Query(args ...interface{}) (*sql.Rows, error) {
	arguments := make([]interface{}, len(args))
	for i, arg := range args {
		arguments[i] = mock.AnythingOfType(arg.(string))
	}
	rows := m.Called(arguments...)
	return rows.Get(0).(*sql.Rows), rows.Error(1)
}

type MockRows struct {
	mock.Mock
}

func (m *MockRows) Scan(dest ...interface{}) error {
	args := m.Called(dest)
	return args.Error(0)
}

type MockResult struct {
	mock.Mock
}

func (m *MockResult) LastInsertId() (int64, error) {
	args := m.Called()
	return args.Get(0).(int64), args.Error(1)
}

func TestCreatePost(t *testing.T) {
	mockDB := new(MockDB)
	mockStmt := new(MockStmt)
	mockResult := new(MockResult)

	ph := NewPostHandler(mockDB)

	e := echo.New()
	req := httptest.NewRequest(http.MethodPost, "/posts", strings.NewReader(`{"title":"Test Title","content":"Test Content"}`))
	req.Header.Set("Content-Type", "application/json")
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	mockDB.On("Prepare", mock.AnythingOfType("string")).Return((*sql.Stmt)(mockStmt), nil)
	mockStmt.On("Exec", mock.AnythingOfType("*string"), mock.AnythingOfType("*string")).Return(mockResult, nil)
	mockResult.On("LastInsertId").Return(int64(1), nil)

	stmt := (*sql.Stmt)(mockStmt) // Type assertion to convert MockStmt to *sql.Stmt

	err := ph.CreatePost(c)
	if assert.NoError(t, err) {
		assert.Equal(t, http.StatusCreated, rec.Code)
		assert.Equal(t, `{"id":1,"title":"Test Title","content":"Test Content","date":""}`, rec.Body.String())
	}

	mockDB.AssertExpectations(t)
	mockStmt.AssertExpectations(t)
	mockResult.AssertExpectations(t)
}


func TestGetPosts(t *testing.T) {
	mockDB := new(MockDB)
	mockStmt := new(MockStmt)
	mockRows := new(MockRows)

	ph := NewPostHandler(mockDB)

	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/posts", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	mockDB.On("Prepare", mock.AnythingOfType("string")).Return(mockStmt, nil)
	mockStmt.On("Query", mock.AnythingOfType("string")).Return(mockRows, nil)
	mockRows.On("Scan", mock.AnythingOfType("*int"), mock.AnythingOfType("*string"), mock.AnythingOfType("*string"), mock.AnythingOfType("*string")).Return(nil)

	err := ph.GetPosts(c)
	if assert.NoError(t, err) {
		assert.Equal(t, http.StatusOK, rec.Code)
		assert.Equal(t, `[{"id":0,"title":"","content":"","date":""}]`, rec.Body.String())
	}

	mockDB.AssertExpectations(t)
	mockStmt.AssertExpectations(t)
	mockRows.AssertExpectations(t)
}

func TestGetPosts_Error(t *testing.T) {
	mockDB := new(MockDB)
	mockStmt := new(MockStmt)
	mockRows := new(MockRows)

	ph := NewPostHandler(mockDB)

	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/posts", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	mockDB.On("Prepare", mock.AnythingOfType("string")).Return(mockStmt, nil)
	mockStmt.On("Query", mock.AnythingOfType("string")).Return(mockRows, errors.New("query error"))

	err := ph.GetPosts(c)
	assert.Error(t, err)

	mockDB.AssertExpectations(t)
	mockStmt.AssertExpectations(t)
	mockRows.AssertExpectations(t)
}
