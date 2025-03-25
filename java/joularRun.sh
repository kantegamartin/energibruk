#!/bin/bash

JAVA=$JAVA_HOME
if [ -z "$JAVA" ]; then
  JAVA=$(mvn --version | grep Java | sed 's/.*runtime: \(.*\)/\1/')
fi
if [ -z "$JAVA" ]; then
  echo Could not find java, set JAVA_HOME to point to a valid Java installation
  exit 1
fi

JAVA="$JAVA/bin/java"
if [ ! -f "$JAVA" ]; then
  echo Could not fine java in $JAVA. Sett JAVA_HOME correctly.
  exit 2
fi

echo "Running java from '$JAVA':"
sudo "$JAVA" -version
JOULAR_AGENT=$(ls -1 joularjx-*.jar | head -n 1)
sudo "$JAVA" -javaagent:$JOULAR_AGENT -cp target/one-billion-row-challenge-1.0.0-SNAPSHOT.jar no.kantega.obrc.Solution $1
