#!/bin/bash

FILE="$1"
if [ -z "$FILE" ]; then
  FILE=measurements.txt
fi

sudo echo "Kjører med '$FILE'"

./nodeRun.sh $FILE &
ID=$!
sudo powerjoular -p $ID -t -f p.out -d &
echo $! > powerjoular.pid

