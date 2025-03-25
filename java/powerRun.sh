#!/bin/bash

if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

JAVA=$JAVA_HOME
if [ -z "$JAVA" ]; then
  JAVA=$(mvn --version | grep Java | sed 's/.*runtime: \(.*\)/\1/')
fi
if [ -z "$JAVA" ]; then
  echo Unable to find java. Set JAVA_HOME to point to a valid Java-installation
  exit 1
fi

JAVA="$JAVA/bin/java"
if [ ! -f "$JAVA" ]; then
  echo Could not fine java in $JAVA. Sett JAVA_HOME correctly.
  exit 2
fi

echo "Running java from '$JAVA':"
"$JAVA" -version
"$JAVA" -cp target/one-billion-row-challenge-1.0.0-SNAPSHOT.jar no.kantega.obrc.Solution &
ID=$!
powerjoular -p $ID -t -f p.out -d
