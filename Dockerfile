FROM golang:latest as build

WORKDIR /go/src
COPY . github.com/webflow/kubekite
WORKDIR /go/src/github.com/webflow/kubekite/cmd/kubekite

# Build and strip our binary
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -a -installsuffix cgo -o kubekite .

FROM ubuntu

ENV GOSU_VERSION 1.13

RUN set -eux; \
  apt clean; \
	apt-get update; \
	apt-get install -y gosu ca-certificates apt-transport-https; \
	rm -rf /var/lib/apt/lists/*; \
	gosu nobody true

# Copy the binary over from the builder image
COPY --from=build /go/src/github.com/webflow/kubekite/cmd/kubekite/kubekite /
RUN chmod +x /kubekite

COPY job-templates/job.yaml /

CMD ["/kubekite"]
