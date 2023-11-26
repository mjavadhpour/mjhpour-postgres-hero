[![Docker Image CI](https://github.com/mjavadhpour/mjhpour-postgres-hero/actions/workflows/docker-image.yml/badge.svg?branch=main)](https://github.com/mjavadhpour/mjhpour-postgres-hero/actions/workflows/docker-image.yml)

This project is aim to create a reference Docker image that collect set of postgres extensions for learning/experimenting purpose.

```sh
docker pull mjhpour/postgres-hero:dev
# or
docker run --rm -p <HOST_PORT>:5432 \
    -e POSTGRES_USER=hero \
    -e POSTGRES_PASSWORD=hero \
    -e POSTGRES_DB=hero \
    mjhpour/postgres-hero:dev
```

#### Extensions Document
- https://github.com/postgres-plr
- https://github.com/apache/age
- https://github.com/iCyberon/pg_hashids
- https://github.com/citusdata/postgresql-hll
- https://github.com/omniti-labs/pg_jobmon
- https://github.com/pgpartman/pg_partman
- https://www.postgresql.org/docs/current/external-projects.html
- https://www.postgresql.org/docs/current/contrib.html
- https://github.com/petere/pguri
- https://github.com/citusdata/pg_cron
- https://github.com/hydradatabase/hydra
- https://github.com/pgvector/pgvector
- https://pgrouting.org/
- https://postgis.net

#### TODO exts:
- https://github.com/neondatabase/pg_embedding
- https://github.com/plv8/plv8
- https://github.com/pgMemento/pgMemento
- https://github.com/citusdata/citus
- https://github.com/orioledb/orioledb
- https://github.com/okbob/pspg
- https://github.com/HypoPG/hypopg
- https://github.com/postgrespro/rum
- https://github.com/postgrespro/pgsphere
- https://github.com/postgrespro/jsquery
- https://github.com/postgrespro/zson
- https://github.com/postgrespro/aqo
- https://github.com/psycopg/psycopg2
- https://github.com/pipelinedb/pipelinedb

