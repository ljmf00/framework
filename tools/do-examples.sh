#!/usr/bin/env bash

set -e

pushd examples

PACKAGES="
gui-simple_window
metadata-detect_files
metadata-pdf_tests
"
#audio-cli_player

for files in $PACKAGES; do
	dub build :$files $@
	dub test :$files $@
done

popd
