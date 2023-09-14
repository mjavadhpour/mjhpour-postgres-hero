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

ARG TZ="Asia/Tehran" \
    POSTGRES_VERSION=15

FROM postgres:${POSTGRES_VERSION}

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
       # plv8
       libtinfo5 build-essential pkg-config libstdc++-12-dev cmake git \
       # pg_cron
       postgresql-${POSTGRES_VERSION}-cron \
       # plr
    #    r-base r-base-dev \
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
    mkdir /tmp/plv8       && git clone "https://github.com/plv8/plv8.git" "/tmp/plv8"                                                                                                     ; \
    mkdir /tmp/pg_jobmon  && wget -qO- "https://github.com/omniti-labs/pg_jobmon/archive/refs/heads/master.tar.gz"                     | tar zxf - -C /tmp/pg_jobmon  --strip-components=1; \
    mkdir /tmp/pg_partman && wget -qO- "https://github.com/pgpartman/pg_partman/archive/refs/heads/master.tar.gz"                      | tar zxf - -C /tmp/pg_partman --strip-components=1; \
    mkdir /tmp/uri        && wget -qO- "https://github.com/petere/pguri/archive/refs/heads/master.tar.gz"                              | tar zxf - -C /tmp/uri        --strip-components=1; \
    # mkdir /tmp/plr        && wget -qO- "https://github.com/postgres-plr/plr/archive/refs/tags/REL8_4_6.tar.gz"                         | tar zxf - -C /tmp/plr        --strip-components=1; \
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
    # plv8
        cd /tmp/plv8 \
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
    # plr
    #     cd /tmp/plr \
    #     && USE_PGXS=1 make && USE_PGXS=1 make install; \
    # \
    # cleanup
        rm -rf /tmp/*;

COPY docker-entrypoint-initdb.d/*-create-extension-*.sql /docker-entrypoint-initdb.d/

WORKDIR /opt/postgres-hero
CMD ["postgres", "-c", "shared_preload_libraries=age,pg_hashids,hll,dblink,plperl,pg_partman_bgw,pg_cron"]

LABEL com.docker.hub.postgres-hero.mjhpour.timezone="${TZ}"
LABEL com.docker.hub.postgres-hero.mjhpour.postgres_version="${POSTGRES_VERSION}"
LABEL com.docker.hub.postgres-hero.mjhpour.os="Debian GNU/Linux 12 (bookworm)"
LABEL com.docker.hub.postgres-hero.mjhpour.extensions="age,pg_hashids,hll,dblink,plpython3u,plperl,plv8,pg_jobmon,pg_partman,uri,pg_cron"
LABEL org.opencontainers.image.base.name="docker.io/postgres:${POSTGRES_VERSION}"
LABEL org.opencontainers.image.description="Extended Postgres ${POSTGRES_VERSION} with pre installed set of open source extensions"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.vendor="M.J. HPour"
