# Postgres container
## This supplements the app to store user data

### How to run
```
docker run --name postgres-latest -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=root -e POSTGRES_DB=postgres -p 5432:5432 -d postgres-local
```
