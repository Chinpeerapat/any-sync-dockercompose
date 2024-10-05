FROM golang:1.22

ARG REPO_DIR=.

# Install necessary packages
RUN apt-get update && apt-get install -y ca-certificates git-core rsync

WORKDIR /app

# Configure Git to use HTTPS
RUN git config --global url.https://github.com/.insteadOf ssh://git@github.com/

# Download Go modules with cache
COPY ${REPO_DIR}/go.mod ${REPO_DIR}/go.sum ./
RUN --mount=type=cache,id=gomod-cache,target=/go/pkg/mod go mod download

COPY ${REPO_DIR} .

# Build with cache
RUN --mount=type=cache,id=deps-cache,target=/app/.deps make deps CGO_ENABLED=0
RUN --mount=type=cache,id=build-cache,target=/app/.build make build CGO_ENABLED=0
RUN rsync -a bin/ /bin/
