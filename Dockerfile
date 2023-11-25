#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ARG TZ="EST" \
    POSTGRES_VERSION=15

FROM ghcr.io/hydradatabase/hydra:${POSTGRES_VERSION}-c29a08455bc8c7af77a8b3d1605b45cf7f96c4bf

ARG POSTGRES_VERSION
RUN apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
       # Image deps
       bison \
       build-essential \
       flex \
       wget \
       # Runtime deps
       locales \
       postgresql-server-dev-${POSTGRES_VERSION} \
       python3-pip postgresql-plpython3-${POSTGRES_VERSION} \
       postgresql-plperl-${POSTGRES_VERSION} \
       postgresql-${POSTGRES_VERSION}-plr \
       # pg_cron
       postgresql-${POSTGRES_VERSION}-cron \
       # uri
       liburiparser-dev \
       pkg-config \
    && rm -rf /var/lib/apt/lists/*

ARG TZ
ENV LANG=en_US.UTF-8 \
    LC_COLLATE=en_US.UTF-8 \
    LC_CTYPE=en_US.UTF-8 \
    TZ=${TZ}

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8; \
    \
    ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo $TZ > /etc/timezone;

RUN set -eux; \
    mkdir /tmp/age        && wget -qO- "https://github.com/apache/age/releases/download/PG15%2Fv1.4.0-rc0/apache-age-1.4.0-src.tar.gz" | tar zxf - -C /tmp/age        --strip-components=1; \
    mkdir /tmp/pg_hashids && wget -qO- "https://github.com/iCyberon/pg_hashids/archive/refs/heads/master.tar.gz"                       | tar zxf - -C /tmp/pg_hashids --strip-components=1; \
    mkdir /tmp/hll        && wget -qO- "https://github.com/citusdata/postgresql-hll/archive/refs/tags/v2.17.tar.gz"                    | tar zxf - -C /tmp/hll        --strip-components=1; \
    mkdir /tmp/pg_jobmon  && wget -qO- "https://github.com/omniti-labs/pg_jobmon/archive/refs/heads/master.tar.gz"                     | tar zxf - -C /tmp/pg_jobmon  --strip-components=1; \
    mkdir /tmp/pg_partman && wget -qO- "https://github.com/pgpartman/pg_partman/archive/refs/heads/master.tar.gz"                      | tar zxf - -C /tmp/pg_partman --strip-components=1; \
    mkdir /tmp/uri        && wget -qO- "https://github.com/petere/pguri/archive/refs/heads/master.tar.gz"                              | tar zxf - -C /tmp/uri        --strip-components=1; \
    mkdir /tmp/faker      && wget -qO- "https://gitlab.com/dalibo/postgresql_faker/-/archive/master/postgresql_faker-master.tar.gz"    | tar zxf - -C /tmp/faker      --strip-components=1; \
    mkdir /tmp/pgvector   && wget -qO- "https://github.com/pgvector/pgvector/archive/refs/tags/v0.5.1.tar.gz"                          | tar zxf - -C /tmp/pgvector   --strip-components=1; \
    \
    # age
        cd /tmp/age \
        && make && make install; \
    \
    # pg_hashids
        cd /tmp/pg_hashids \
        && USE_PGXS=1 make && SE_PGXS=1 make install; \
    \
    # hll
        cd /tmp/hll \
        && make && make install; \
    \
    # pg_jobmon
        cd /tmp/pg_jobmon \
        && make && make install; \
    \
    # pg_partman
        cd /tmp/pg_partman \
        && make install; \
    \
    # uri
        cd /tmp/uri \
        && make && make install; \
    \
    # faker
        cd /tmp/faker \
        && pip3 install faker --break-system-packages \
        && make extension && make install; \
    \
    # pgvector
        cd /tmp/pgvector \
        && make && make install; \
    \
    # cleanup
        rm -rf /tmp/*;

COPY docker-entrypoint-initdb.d/00-create-extension-contrib.sql /docker-entrypoint-initdb.d/00-create-extension-contrib.sql
COPY docker-entrypoint-initdb.d/01-create-extension.sql /docker-entrypoint-initdb.d/01-create-extension.sql

LABEL com.docker.hub.postgres-hero.mjhpour.timezone="${TZ}"
LABEL com.docker.hub.postgres-hero.mjhpour.postgres_version="${POSTGRES_VERSION}"
LABEL com.docker.hub.postgres-hero.mjhpour.os="Debian GNU/Linux 12 (bookworm)"
LABEL com.docker.hub.postgres-hero.mjhpour.extensions="age,pg_hashids,hll,dblink,plpython3u,plperl,pg_jobmon,pg_partman,uri,pg_cron"
LABEL org.opencontainers.image.base.name="docker.io/postgres:${POSTGRES_VERSION}"
LABEL org.opencontainers.image.description="Extended Postgres ${POSTGRES_VERSION} with pre installed set of open source extensions"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.vendor="M.J. HPour"
