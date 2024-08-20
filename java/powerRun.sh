#!/bin/bash

if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

/home/martin/.sdkman/candidates/java/21.0.3-tem/bin/java -cp target/one-billion-row-challenge-1.0.0-SNAPSHOT.jar no.kantega.obrc.Solution &
ID=$!
powerjoular -p $ID -t -f p.out -d
