FROM golang:1.18-bullseye AS build

WORKDIR /build
COPY ./Makefile ./
COPY ./go.mod ./
COPY ./go.sum ./
COPY ./cmd ./cmd
COPY ./pkg ./pkg

RUN make linux

FROM gcr.io/distroless/static:debug AS debug
LABEL description="A lightweight Go Web Server that accepts POST alert message from Prometheus Alertmanager and sends it to Microsoft Teams Channels using an incoming webhook url."
EXPOSE 2000

# Copy required cert and zoneinfo from previous stage
#COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /build/bin/prometheus-msteams-linux-amd64 /promteams

COPY ./default-message-card.tmpl /default-message-card.tmpl
#COPY bin/prometheus-msteams-linux-amd64 /promteams

ENTRYPOINT ["/promteams"]

FROM gcr.io/distroless/static
LABEL description="A lightweight Go Web Server that accepts POST alert message from Prometheus Alertmanager and sends it to Microsoft Teams Channels using an incoming webhook url."
EXPOSE 2000

# Copy required cert and zoneinfo from previous stage
#COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /build/bin/prometheus-msteams-linux-amd64 /promteams

COPY ./default-message-card.tmpl /default-message-card.tmpl
#COPY bin/prometheus-msteams-linux-amd64 /promteams

ENTRYPOINT ["/promteams"]
