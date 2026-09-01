# Justfile for Spinel (spinel.md)

default: list

# List all available recipes
list:
    @just -l

# Run all tests across modules
test: test-cli

# Run Go CLI unit and integration tests
test-cli:
    cd cli && go test -v ./...

# Build standalone Go CLI binary
build-cli:
    cd cli && go build -o ../bin/spinel ./cmd/spinel

# Run Go CLI with arguments
run-cli *ARGS:
    cd cli && go run ./cmd/spinel {{ARGS}}
