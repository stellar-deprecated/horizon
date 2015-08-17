#! /usr/bin/env bash

set -e

mcdev-each-change -gb gb test {{.Pkg}}
