#!/bin/bash

rm -Rf doc/api
dartdoc -q --header doc/header.html --hosted-url dalk.io --exclude sdk_interop
cp -Rf doc ../../../dalkWebsite/
