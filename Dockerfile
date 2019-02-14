# Copyright 2018 Marcos Rafael Kaissi Barbosa
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM wnameless/oracle-xe-11g:18.04
ARG HEALTH_PORT_TARGET=8081
ENV HEALTH_PORT_TARGET ${HEALTH_PORT_TARGET}
ARG HEALTH_READINESS_FILE="readiness"
ENV HEALTH_READINESS_FILE ${HEALTH_READINESS_FILE}
ARG TZ="Etc/UTC"
ENV TZ ${TZ}
COPY entrypoint /usr/local/oracle/
COPY ${HEALTH_READINESS_FILE} /usr/local/oracle/
COPY --from=kaissi/health-server:1.0.0 /usr/local/health-server/health-server /usr/local/oracle/
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
            dumb-init=1.2.* \
            tzdata \
        && apt-get autoremove -y \
        && apt-get clean all \
        && rm -rf /var/lib/apt/lists/* \
    && unlink /etc/localtime \
        && ln -s /usr/share/zoneinfo/${TZ} /etc/localtime \
        && dpkg-reconfigure -f noninteractive tzdata \
    && ln -s /usr/local/oracle/entrypoint /usr/local/bin/entrypoint \
    && ln -s /usr/local/oracle/${HEALTH_READINESS_FILE} /usr/local/bin/${HEALTH_READINESS_FILE} \
    && ln -s /usr/local/oracle/health-server /usr/local/bin/health-server
EXPOSE 1521
EXPOSE 8080
EXPOSE ${HEALTH_PORT_TARGET}
ENTRYPOINT ["/usr/bin/dumb-init", "--", "entrypoint"]
