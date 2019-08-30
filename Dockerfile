FROM i386/golang:1.12.9-buster as gobuild
ARG PROMETHEUS_VERSION=2.12.0
ENV DOCKER_TAG ${PROMETHEUS_VERSION}
WORKDIR ${GOPATH}/src
RUN git clone http://github.com/prometheus/prometheus.git --single-branch --branch v${PROMETHEUS_VERSION} --depth=1
WORKDIR ${GOPATH}/src/prometheus
RUN make build
FROM i386/alpine
ENV USER prometheus
ENV UID 9090
ENV GID 9090
RUN addgroup --gid "${GID}" "${USER}" \
    && adduser \
    --disabled-password \
    --gecos "" \
    --ingroup "${USER}" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"
COPY --from=gobuild /go/src/prometheus/prometheus /prometheus/prometheus
COPY --from=gobuild /go/src/prometheus/promtool /prometheus/promtool
COPY --from=gobuild /go/src/prometheus/documentation/examples/prometheus.yml /prometheus/prometheus.yml
RUN mkdir /data && chown -R ${UID}:${GID} /data
USER ${UID}:${GID}
EXPOSE 9090
ENTRYPOINT [ "/prometheus/prometheus"] 
CMD ["--config.file=/prometheus/prometheus.yml"]
