#!/bin/bash

rm -Rf doc/api
dartdoc -q --header doc/header.html --hosted-url dalk.io
rm -Rf ../../../dalkWebsite/doc/api
cp -Rf doc ../../../dalkWebsite/
