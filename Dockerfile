FROM golang:1.18-bullseye AS build

WORKDIR /build

COPY ./Makefile ./
COPY ./go.mod ./
COPY ./go.sum ./
COPY ./cmd ./cmd
COPY ./pkg ./pkg
COPY ./default-message-card.tmpl ./
COPY ./.git ./.git

RUN make linux
RUN make test

FROM gcr.io/distroless/static-debian11:debug@sha256:08ac4c939c472a3b16f7739d98a384c6aa84784abc4f375dbbb50573bd35caec AS debug
LABEL description="A lightweight Go Web Server that accepts POST alert message from Prometheus Alertmanager and sends it to Microsoft Teams Channels using an incoming webhook url."
EXPOSE 2000

WORKDIR /app

COPY --from=build /build/bin/prometheus-msteams-linux-amd64 ./promteams
COPY ./default-message-card.tmpl ./default-message-card.tmpl

ENTRYPOINT ["/app/promteams"]

FROM gcr.io/distroless/static-debian11:latest@sha256:d6fa9db9548b5772860fecddb11d84f9ebd7e0321c0cb3c02870402680cc315f
LABEL description="A lightweight Go Web Server that accepts POST alert message from Prometheus Alertmanager and sends it to Microsoft Teams Channels using an incoming webhook url."

USER nonroot:nonroot

WORKDIR /app

EXPOSE 2000

COPY --from=build --chown=nonroot:nonroot /build/bin/prometheus-msteams-linux-amd64 ./promteams
COPY --chown=nonroot:nonroot ./default-message-card.tmpl ./default-message-card.tmpl

ENTRYPOINT ["/app/promteams"]
