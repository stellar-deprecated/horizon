#! /usr/bin/env bash
set -e

DIST="dist"
VERSION=$(git describe --always --dirty --tags)
GOARCH=amd64
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CURRENT_GOOS="$(go run $DIR/current_os.go)"

build() {
	GOOS=$1
	RELEASE="horizon-$VERSION-$GOOS-$GOARCH"
	PKG_DIR="$DIST/$RELEASE"

	# do the actual build
	GOOS=$GOOS GOARCH=$GOARCH gb build

	# make package directory
	rm -rf $PKG_DIR
	mkdir -p $PKG_DIR
	cp bin/$(srcBin $GOOS) $PKG_DIR/$(destBin $GOOS)
	cp LICENSE.txt $PKG_DIR/
	cp README.md $PKG_DIR/

	# TODO: add platform specific install intstructions

	# zip/tar package directory
	pkg $GOOS $RELEASE
}

srcBin() {
	GOOS=$1
	BIN="horizon"

	if [ "$GOOS" != "$CURRENT_GOOS" ]; then
		BIN+="-$GOOS-$GOARCH"
	fi

	if [ "$GOOS" = "windows" ]; then
		BIN+=".exe"
	fi

	echo $BIN
}

destBin() {
	if [ "$1" = "windows" ]; then
		echo "horizon.exe"
	else
		echo "horizon"
	fi
}

pkg() {
	GOOS=$1
	RELEASE=$2

	if [ "$GOOS" = "windows" ]; then
		pushd $DIST
		zip $RELEASE.zip $RELEASE/*
		popd
	else
		tar -czf $DIST/$RELEASE.tar.gz -C $DIST $RELEASE
	fi

	rm -rf $DIST/$RELEASE
}

build darwin
build linux
build windows
