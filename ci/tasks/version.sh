#!/bin/sh
# fix for Git resource deleting tags
# https://github.com/concourse/git-resource/issues/183
git fetch --tags

VERSION=$(git describe --first-parent --match '[[:digit:]]*.[[:digit:]]*')
if [ $? -ne 0 ]
then
    VERSION=$(git rev-parse --short HEAD)
fi

echo $VERSION