# Justfile for Spinel (spinel.md)

default: list

# List all available recipes
list:
    @just -l

# Run all tests across modules (Go CLI, Flutter App, Rails Server, Terraform)
test: test-cli test-app test-server test-infra

# Run Go CLI unit and integration tests
test-cli:
    cd cli && go test -v ./...

# Run Flutter app unit and widget tests
test-app:
    cd app && flutter test

# Run Rails 8 API backend RSpec test suite
test-server:
    cd server && bundle exec rspec

# Validate Terraform infrastructure
test-infra:
    cd infra && terraform fmt -check && terraform validate

# Build standalone Go CLI binary
build-cli:
    cd cli && go build -o ../bin/spinel ./cmd/spinel

# Run Go CLI with arguments
run-cli *ARGS:
    cd cli && go run ./cmd/spinel {{ARGS}}

# Run Flutter desktop app on macOS
run-app:
    cd app && flutter run -d macos

# Serve GitHub Pages landing page locally
serve-docs PORT="8000":
    @echo "🚀 Serving Spinel landing page at http://localhost:{{PORT}}"
    python3 -m http.server {{PORT}} --directory docs

# Validate documentation assets and HTML markup
test-docs:
    python3 bin/verify_docs.py
