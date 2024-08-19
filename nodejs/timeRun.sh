#!/bin/bash

FILE="$1"
if [ -z "$FILE" ]; then
  FILE=measurements.txt
fi

time node baseline/index.js $FILE