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
    mkdir /tmp/plv8       && wget -qO- "https://github.com/plv8/plv8/archive/refs/tags/v3.2.0.tar.gz"                                  | tar zxf - -C /tmp/plv8       --strip-components=1; \
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
    # plr
    #     cd /tmp/plr \
    #     && USE_PGXS=1 make && USE_PGXS=1 make install; \
    # \
    # cleanup
        rm -rf /tmp/*;

COPY docker-entrypoint-initdb.d/*-create-extension-*.sql /docker-entrypoint-initdb.d/

WORKDIR /opt/postgres-hero
CMD ["postgres", "-c", "shared_preload_libraries=age,pg_hashids,hll,dblink,plpython3u,plperl,plv8"]

LABEL TIMEZONE="${TZ}"
LABEL BASE_IMAGE="postgres:15"
LABEL POSTGRES_VERSION="${POSTGRES_VERSION}"
LABEL OS="Debian GNU/Linux 12 (bookworm)"
LABEL EXTENSIONS="age,pg_hashids,hll,dblink,plpython3u,plperl,plv8"
