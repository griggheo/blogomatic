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
# edit blog/src/App.css
```

Install go coverage tools:

```
$ go install github.com/axw/gocov/...
$ go install github.com/AlekSi/gocov-xml
```

Add $HOME/go/bin to $PATH.

Install SonarScanner CLI

```
$ wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip
$ unzip sonar-scanner-cli-4.8.0.2856-linux.zip
$ sudo mv sonar-scanner-cli-4.8.0.2856-linux /opt
$ sudo ln -s /opt/sonar-scanner-cli-4.8.0.2856-linux /opt/sonar-scanner
$ rm -rf sonar-scanner-cli-4.8.0.2856-linux.zip
```

Add /opt/sonar-scanner/bin to $PATH.
