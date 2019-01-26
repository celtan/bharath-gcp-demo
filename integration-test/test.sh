#!/bin/bash

HOST=35.189.23.120

for i in $(seq 1 1000); do
curl -X POST \
  http://${HOST}:8080/api/ \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache' \
  -d '{
    "username": "test${i}",
    "password": "pass${i}"
}'
done
# curl -X GET http://localhost:8080/api

# curl -X GET http://localhost:8080/api/1

