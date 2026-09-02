# Implementation Plan: Track 2 - GCP Cloud SQL Sync Engine, Rails 8 API & Terraform Infra

## Phase 1: Declarative Terraform Infrastructure (`infra/`)
- [ ] Task: Set up modular Terraform configuration (`main.tf`, `variables.tf`, `cloud_sql.tf`, `cloud_run.tf`, `secret_manager.tf`, `outputs.tf`)
- [ ] Task: Validate Terraform syntax and configuration with `terraform fmt` and `terraform validate`
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 2: Rails 8 API Scaffolding & Database Modeling (`server/`)
- [ ] Task: Scaffold Rails 8 API application with PostgreSQL database configuration and Dockerfile
- [ ] Task: Write RSpec unit tests for Vault and Note models with JSONB frontmatter indexing
- [ ] Task: Implement Note and Vault models with content hashing, soft deletes, and JSONB scopes
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 3: Sync & Query API Endpoints with TDD (`server/`)
- [ ] Task: Write RSpec request specs for Bearer token authentication and delta sync endpoint
- [ ] Task: Implement `/api/v1/sync/delta` controller with timestamp versioning and conflict resolution
- [ ] Task: Write RSpec request specs for JSONB frontmatter querying (`/api/v1/notes/query`)
- [ ] Task: Implement frontmatter search endpoint utilizing PostgreSQL GIN index
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 4: Client Sync Integration & Encryption (`cli/` & `app/`)
- [ ] Task: Write unit tests for Go CLI zero-knowledge encryption (AES-256-GCM) and delta sync client
- [ ] Task: Implement `spinel sync` command in Go CLI
- [ ] Task: Implement `SyncService` client provider in Flutter app
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 5: End-to-End Verification & Justfile Automation
- [ ] Task: Add `Justfile` recipes for server tests, local server run, and Terraform verification
- [ ] Task: Perform end-to-end sync verification between two vaults via Rails API
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)
