#!/bin/bash

rm -Rf doc/api
dartdoc -q --header doc/header.html --hosted-url dalk.io --exclude dalk_sdk_js
rm -Rf ../../../dalkWebsite/doc/api
cp -Rf doc ../../../dalkWebsite/
