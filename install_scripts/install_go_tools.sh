#!/bin/bash

# Install gotestsum
go install gotest.tools/gotestsum@latest

# Install go coverage tools
go get github.com/axw/gocov/...
go install github.com/axw/gocov/...
go get github.com/AlekSi/gocov-xml
go install github.com/AlekSi/gocov-xml

# Install govulncheck
go install golang.org/x/vuln/cmd/govulncheck@latest

echo Make sure you set PATH=$HOME/go/bin:$PATH
