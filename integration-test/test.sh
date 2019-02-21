#!/bin/bash

HOST=35.201.13.99

for i in $(seq 10000 20000); do
curl -X POST \
  http://${HOST}:80/api/ \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache' \
  -d "{
    \"username\": \"test${i}\",
    \"password\": \"pass${i}\"
}"
done
# curl -X GET http://localhost:8080/api

# curl -X GET http://localhost:8080/api/1

