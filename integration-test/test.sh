#!/bin/bash

curl -X POST \
  http://localhost:8080/api/ \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache' \
  -d '{
    "username": "bharath12",
    "password": "pass123"
}'

curl -X GET http://localhost:8080/api

curl -X GET http://localhost:8080/api/1

