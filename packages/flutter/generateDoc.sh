#!/bin/bash

rm -Rf doc/api
dartdoc -q --header doc/header.html --hosted-url dalk.io --include 'dalk_sdk,flutter_dalk_sdk' --auto-include-dependencies
cp -Rf doc ../../../dalkWebsite/
