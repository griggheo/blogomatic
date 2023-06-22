#!/bin/bash

# Install go coverage tools
go get github.com/axw/gocov/...
go install github.com/axw/gocov/...
go get github.com/AlekSi/gocov-xml
go install github.com/AlekSi/gocov-xml
echo Make sure you set PATH=$HOME/go/bin:$PATH
