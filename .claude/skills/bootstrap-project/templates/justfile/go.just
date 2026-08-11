
# ---- app ----

dev: compose-up
    go run ./cmd/{{PROJECT}}

build:
    go build -o bin/{{PROJECT}} ./cmd/{{PROJECT}}

test:
    go test ./...

static-qa:
    gofmt -l . | tee /dev/stderr | (! read)
    go vet ./...
    golangci-lint run

static-fix:
    gofmt -w .
    golangci-lint run --fix || true
