#!/bin/bash

JAVA=$JAVA_HOME
if [ -z "$JAVA" ]; then
  JAVA=$(mvn --version | grep Java | sed 's/.*runtime: \(.*\)/\1/')
fi
if [ -z "$JAVA" ]; then
  echo Fant ikke java, sett JAVA_HOME til å peke på en gyldig Java-installasjon
  exit 1
fi

JAVA="$JAVA/bin/java"
if [ ! -f "$JAVA" ]; then
  echo Fant ikke java i $JAVA. Sett JAVA_HOME rett.
  exit 2
fi

echo "Kjører java fra '$JAVA':"
sudo "$JAVA" -version
sudo "$JAVA" -javaagent:joularjx-3.0.0.jar -cp target/one-billion-row-challenge-1.0.0-SNAPSHOT.jar no.kantega.obrc.Solution $1
