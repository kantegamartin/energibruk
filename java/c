#!/bin/bash

if [ -z "$1" ]; then
  echo "Angi en fil å se på. F.x. 'filtered-methods-energy'"
  exit 1
fi

FILE=$(find joularjx-result/ -iname *$1*)

if [ -z "$FILE" ]; then
  echo "Fant ikke '$1'".
  exit 2
fi
if [ ! -f "$FILE" ]; then
  echo "Fant for mange filer som matcher '$1'. Spesifiser mer."
  echo "$FILE"
  exit 3
fi

echo "Sortert innhold av '$(basename $FILE)' i '$(dirname $FILE)':"
echo cat $FILE \| awk -F ',' '{print $2 " " $1}' \| sort -rn
cat $FILE | awk -F ',' '{print $2 " " $1}' | sort -rn