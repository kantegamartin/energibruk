#!/bin/bash

DIR=$PWD
cd $(dirname $0)

JAR=java/target/average-1.0.0-SNAPSHOT.jar
if [ ! -f $JAR ]; then
  cd java
  mvn package
  if [ ! $? ]; then
    echo "Build failed. Exiting"
    exit
  fi
  cd ..
fi

ANTALL=$1
if [ -z "$ANTALL" ]; then
  # Default 10 mill
  ANTALL=10000000
fi

java -cp $JAR dev.morling.onebrc.CreateMeasurements $ANTALL

if [ $PWD != $DIR ]; then
  mv measurements.txt $DIR
fi