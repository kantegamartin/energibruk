#!/bin/bash

DOCKER_ID=$(pidof docker)
sudo echo "Running for PID: $DOCKER_ID"
sudo powerjoular -p $DOCKER_ID -t -f p.out &
POWER_ID=$!
# psql -h localhost -d sustainability -U postgres -f test.sql
psql postgresql://postgres:postgres@localhost:5432/sustainability -f test.sql
kill -2 $POWER_ID