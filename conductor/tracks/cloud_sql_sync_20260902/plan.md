# Implementation Plan: Track 2 - GCP Cloud SQL Sync Engine, Rails 8 API & Terraform Infra

## Phase 1: Declarative Terraform Infrastructure (`infra/`)
- [x] Task: Set up modular Terraform configuration (`main.tf`, `variables.tf`, `cloud_sql.tf`, `cloud_run.tf`, `secret_manager.tf`, `outputs.tf`)
- [x] Task: Validate Terraform syntax and configuration with `terraform fmt` and `terraform validate`
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 2: Rails 8 API Scaffolding & Database Modeling (`server/`)
- [x] Task: Scaffold Rails 8 API application with PostgreSQL database configuration and Dockerfile
- [x] Task: Write RSpec unit tests for Vault and Note models with JSONB frontmatter indexing
- [x] Task: Implement Note and Vault models with content hashing, soft deletes, and JSONB scopes
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 3: Sync & Query API Endpoints with TDD (`server/`)
- [x] Task: Write RSpec request specs for Bearer token authentication and delta sync endpoint
- [x] Task: Implement `/api/v1/sync/delta` controller with timestamp versioning and conflict resolution
- [x] Task: Write RSpec request specs for JSONB frontmatter querying (`/api/v1/notes/query`)
- [x] Task: Implement frontmatter search endpoint utilizing PostgreSQL GIN index
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 4: Client Sync Integration & Encryption (`cli/` & `app/`)
- [x] Task: Write unit tests for Go CLI zero-knowledge encryption (AES-256-GCM) and delta sync client
- [x] Task: Implement `spinel sync` command in Go CLI
- [x] Task: Implement `SyncService` client provider in Flutter app
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 5: End-to-End Verification & Justfile Automation
- [x] Task: Add `Justfile` recipes for server tests, local server run, and Terraform verification
- [x] Task: Perform end-to-end sync verification between two vaults via Rails API
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md)
