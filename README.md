# blogomatic
Blog application using the Echo golang web framework

## Local bootstraping

```
# create main.go
$ go mod init github.com/codepraxis-io/blogomatic
$ go mod tidy
```

Create React frontend:

```
$ mkdir web; cd web
$ npx create-react-app blog
# edit blog/src/App.js
```

Install Material UI:

```
$ cd web
$ npm install @mui/material @emotion/react @emotion/styled
```

