# Performance tests

## Tool used - Artillery.io

Artillery is a modern, powerful, easy-to-use load-testing toolkit. Artillery has a strong focus on developer happiness & ease of use, and a batteries-included philosophy.

## How to run

```
$ nohup artillery run load_test_id.config > load_test_byId.out 2>&1
$ nohup artillery run load_test_post.config > load_test_createItem.out 2>&1
$ nohup artillery run load_test.config > load_test_fullTableScan.out 2>&1
```

## Note

Please ensure you have a sufficiently large compute node when running these tests.
Recommended compute node: 2 vCPUs and 4 GB RAM

## Misc

```
curl -s http://${INGRESS_HOST}/api | jq length
```
