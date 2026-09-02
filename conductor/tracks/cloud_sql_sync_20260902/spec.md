# Specification: Track 2 - GCP Cloud SQL Sync Engine, Rails 8 API & Terraform Infra

## 1. Overview
Implement the cloud synchronization layer for Spinel:
- **Backend API:** Rails 8 API-only service (`server/`) deployed on Google Cloud Run.
- **Database:** Google Cloud SQL for PostgreSQL with `JSONB` frontmatter indexing and `pgcrypto`/`pgvector`.
- **Infrastructure as Code:** 100% idempotent Terraform footprint (`infra/`) provisioning Cloud SQL, Cloud Run, Secret Manager, and IAM.
- **Client Sync Protocol:** Delta synchronization with content hashing, timestamp versioning, and zero-knowledge encrypted payloads (AES-256-GCM + Argon2id).
- **CLI & Flutter Sync Clients:** `spinel sync` CLI command and automatic background sync in Flutter.

## 2. Functional Requirements
### 2.1 Terraform Footprint (`infra/`)
- Declarative, idempotent GCP infrastructure:
  - Google Cloud SQL (PostgreSQL 16) with automated daily backups and SSL enforcement.
  - Google Cloud Run service with minimal container footprint and autoscaling to zero.
  - Secret Manager for database credentials and Rails master key.
  - IAM least-privilege service accounts and Cloud SQL client bindings.

### 2.2 Rails 8 API Server (`server/`)
- API endpoints:
  - `POST /api/v1/auth/token`: Authenticate vault with bearer token.
  - `POST /api/v1/sync/delta`: Submit client note deltas (updated/created/deleted) and receive server deltas since timestamp.
  - `GET /api/v1/notes/query`: Query notes by frontmatter JSONB properties (e.g. `tags ? 'sre'`, `author = 'Riccardo'`).
  - `POST /api/v1/vault/backup`: Request server-side point-in-time snapshot.
- PostgreSQL Schema:
  - `notes`: `id` (UUID), `vault_id` (UUID), `relative_path` (string), `encrypted_body` (text), `frontmatter` (JSONB + GIN index), `content_hash` (string), `version` (bigint), `deleted_at` (datetime), `timestamps`.

### 2.3 Client Sync Integration
- **Go CLI (`spinel sync`):** Push/pull local `.md` changes against the Rails Cloud Run endpoint.
- **Flutter Client Sync Engine:** Background sync worker detecting local file modifications and syncing with the cloud backend.

## 3. Non-Functional Requirements
- **Zero-Knowledge Security:** The Rails API and PostgreSQL database NEVER receive unencrypted note text or master encryption keys.
- **Idempotency:** Re-running Terraform or re-sending sync deltas produces identical, safe states without duplication or corruption.
- **Fast Response Times:** Single-digit millisecond latency for delta queries via indexed JSONB and content hashes.

## 4. Acceptance Criteria
- [ ] Terraform configuration validates with `terraform validate` and `terraform fmt`.
- [ ] Rails 8 API unit/request specs pass with >85% coverage via `bundle exec rspec`.
- [ ] Go CLI `spinel sync` pushes encrypted notes to local/mock Rails server and pulls updates.
- [ ] Frontmatter JSONB queries in PostgreSQL return matching notes without scanning full tables.
