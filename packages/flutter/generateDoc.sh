#!/bin/bash

rm -Rf doc/api
if [ -z "$FLUTTER_ROOT" ]; then
  export FLUTTER_ROOT=~/flutter
fi
dartdoc -q --header doc/header.html --include 'dalk_sdk,flutter_dalk_sdk' --auto-include-dependencies
cp -Rf doc ../../../dalkWebsite/
