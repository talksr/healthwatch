# healthwatch

[![CI](https://github.com/talksr/healthwatch/actions/workflows/ci.yml/badge.svg)](https://github.com/talksr/healthwatch/actions/workflows/ci.yml)

A small service that polls HTTP endpoints and exposes their status as JSON and Prometheus metrics. I built it to practise the full loop of a containerised service: code, tests, CI, image build, and monitoring.

## What it does

- Checks a list of URLs on a fixed interval (default 30s)
- Marks a target **down** on a 4xx/5xx response, connection error or timeout
- Serves:
  - `GET /status`: latest result per target (JSON)
  - `GET /metrics`: Prometheus metrics (`healthwatch_up`, `healthwatch_latency_seconds`)
  - `GET /healthz`: liveness probe

## Run it

```bash
docker compose up --build -d
curl localhost:8000/status
# Prometheus UI: http://localhost:9090  (try the query: healthwatch_up)
```

Or without Docker:

```bash
make install
make run
```

## Configuration

| Variable | Default | Description |
|---|---|---|
| `TARGETS` | `https://example.com,https://github.com` | Comma-separated URLs to check |
| `CHECK_INTERVAL_SECONDS` | `30` | Time between check rounds |
| `CHECK_TIMEOUT_SECONDS` | `5` | Per-request timeout |

## DevOps bits

- **Dockerfile**: slim base image, non-root user, built-in `HEALTHCHECK`, pinned dependencies
- **docker-compose**: runs the app alongside Prometheus, pre-wired to scrape it
- **GitHub Actions**: lint (ruff) and tests (pytest) on every push and PR, then a Docker build; on `main` the image is pushed to GitHub Container Registry
- **Tests**: unit tests with mocked HTTP, so CI never depends on the network

## Design notes

- The poller runs in a background thread inside the app, so gunicorn runs a single worker to avoid duplicate checks. A production version would split the poller into its own process or use a scheduler.
- Metrics use a dedicated registry rather than the global default, which keeps tests isolated.

## Ideas for next steps

- Alertmanager rules for `healthwatch_up == 0`
- A Grafana dashboard provisioned from JSON
- Terraform to deploy the container to a small cloud VM

## Licence

MIT
