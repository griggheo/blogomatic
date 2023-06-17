# blogomatic
Blog application using the Echo golang web framework

## Prerequisite installation

Install utilities

```
$ sudo apt install -y build-essential sqlite3 jq unzip
```

Install go 1.20 on Ubuntu 22.04

```
VERSION=1.20.5

wget https://go.dev/dl/go${VERSION}.linux-amd64.tar.gz
tar xvfz go${VERSION}.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo mv go /usr/local
rm -rf go${VERSION}.linux-amd64.tar.gz
echo Make sure you set PATH=/usr/local/go/bin:$PATH
```

Install node 18.x / npm 9.x on Ubuntu 22.04

```
$ curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
$ sudo bash nodesource_setup.sh
$ rm nodesource_setup.sh 
$ sudo apt-get install -y nodejs
$ npm version
```

Install go coverage tools:

```
$ go get github.com/axw/gocov/...
$ go install github.com/axw/gocov/...
$ go get github.com/AlekSi/gocov-xml
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

