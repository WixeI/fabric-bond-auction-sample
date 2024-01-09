#!/bin/bash

#
# 1. Serve Rest API
#

cd ../bond-auction/rest-api

go mod download

go run main-org2.go
