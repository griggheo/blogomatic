# blogomatic
Blog application using the Echo golang web framework

## Prerequisite installation


o  staff   215 Jun 27 07:14 install_cosign.sh
-rwxr-xr-x   1 ggheo  staff   230 Jun 27 07:14 install_go_tools.sh
-rwxr-xr-x   1 ggheo  staff   549 Jun 27 07:14 install_languages.sh
-rwxr-xr-x   1 ggheo  staff  1095 Jun 27 07:14 install_sbom_tools.sh
-rwxr-xr-x   1 ggheo  staff   915 Jun 27 07:14 install_security_scanning_tools.sh
-rwxr-xr-x   1 ggheo  staff  1033 Jun 27 07:14 install_sq_owasp_scanners.sh
-rwxr-xr-x   1 ggheo  staff    65 Jun 27 07:14 install_ubuntu_packages.sh

Install Ubuntu packages

```
$./scripts/install_ubuntu_packages.sh
```

Install languages (go, npm, java)

```
$ ./scripts/install_languages.sh
```

Install go tools (test coverage)

```
$ ./scripts/go_tools.sh
```

Install SBOM tools

```
$ ./scripts/install_sbom_tools.sh
```

Install scanning tools (SonarQube Scanner, OWASP Dependency Check)

```
$./scripts/install_sq_owasp_scanners.sh
```

Install security scanning tools (trivy, syft, grype, hadolint)

```
$./scripts/install_security_scanning_tools.sh
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

