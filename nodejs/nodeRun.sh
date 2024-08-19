#!/bin/bash

node baseline/index.js "$1"
PID=$(cat powerjoular.pid)
kill -2 $PID