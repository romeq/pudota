#!/bin/sh

if ! openssl enc -aes-256-cbc -pbkdf2 -e -in "backup.tar.gz" -out backup.tar.gz.enc; then
    exit 1
fi

shred -u backup.tar.gz || rm -f backup.tar.gz
