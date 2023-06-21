# blogomatic
Blog application using the Echo golang web framework

## Prerequisite installation

Install Ubuntu packages

```
$./scripts/install_ubuntu_packages.sh
```

Install languages (go, npm) and test coverage tools

```
$ ./scripts/install_languages.sh
```

Install SBOM tools

```
$ ./scripts/install_sbom_tools.sh
```

Install scanning tools (SonarQube Scanner, OWASP Dependency Check)
```
$./scripts/install_scanning_tools.sh
```

## Project  bootstraping

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
# edit blog/src/App.css
```

