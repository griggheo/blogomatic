# blogomatic
Blog application using the Echo golang web framework

## Prerequisite installation


Install Ubuntu packages

```
$./install_scripts/install_ubuntu_packages.sh
```

Install languages (go, npm, java)

```
$ ./install_scripts/install_languages.sh
```

Install go tools (test coverage)

```
$ ./install_scripts/go_tools.sh
```

Install SBOM tools

```
$ ./install_scripts/install_sbom_tools.sh
```

Install scanning tools (SonarQube Scanner, OWASP Dependency Check)

```
$./install_scripts/install_sq_owasp_scanners.sh
```

Install security scanning tools (trivy, syft, grype, hadolint)

```
$./install_scripts/install_security_scanning_tools.sh
```
Install goreleaser: https://goreleaser.com/install/


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

