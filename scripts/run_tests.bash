#! /usr/bin/env bash

set -e

go test  $(go list ./... | grep -v "/vendor/")
