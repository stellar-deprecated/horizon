#! /usr/bin/env bash

set -e

pushd docs
hugo server -w -t hyde -D
popd