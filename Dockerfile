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
       # faker
       postgresql-plpython3-${POSTGRES_VERSION} \
       python3-pip \
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

WORKDIR /opt/postgres-ext

RUN set -eux; \
    mkdir /tmp/faker && wget -qO- "https://gitlab.com/dalibo/postgresql_faker/-/archive/master/postgresql_faker-master.tar.gz"    | tar zxf - -C /tmp/faker --strip-components=1; \
    mkdir /tmp/age   && wget -qO- "https://github.com/apache/age/releases/download/PG15%2Fv1.4.0-rc0/apache-age-1.4.0-src.tar.gz" | tar zxf - -C /tmp/age   --strip-components=1; \
    \
    # faker
        cd /tmp/faker \
        && pip3 install -r requirements.txt \
        && make && make install; \
    \
    # age
        cd /tmp/age \
        && make && make install; \
    \
    # cleanup
        rm -rf /tmp/faker /tmp/age;

COPY docker-entrypoint-initdb.d/00-create-extension-*.sql /docker-entrypoint-initdb.d/

CMD ["postgres", "-c", "shared_preload_libraries=age,faker"]

LABEL timezone="${TZ}"
LABEL image_base="postgres:15"
LABEL postgres_version="${POSTGRES_VERSION}"
