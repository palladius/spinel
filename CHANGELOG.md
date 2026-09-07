# Changelog

All notable changes to the Spinel project will be documented in this file.

## [0.3.0] - 2026-09-07
### Added
- **Idempotent Terraform GCP Footprint (`infra/`)**: Fully declarative infrastructure provisioning Google Cloud SQL (PostgreSQL 16), Cloud Run v2 service, Secret Manager for credentials/master key, and least-privilege IAM bindings.
- **Rails 8 API Cloud Backend (`server/`)**: API-only service on Ruby 3.4 / Rails 8 with PostgreSQL JSONB frontmatter indexing, bearer token authentication, soft delete support, and delta sync endpoints.
- **Zero-Knowledge Encryption Engine (`cli/pkg/crypto`)**: AES-256-GCM symmetric encryption with SHA-256 key derivation ensuring notes are never stored unencrypted on the cloud.
- **CLI Sync Command (`spinel sync`)**: Synchronizes local vaults with the Rails/Cloud SQL backend via content hashing and delta conflict resolution.
- **Multi-Module Testing in Justfile**: Added `test-server` (RSpec), `test-infra` (Terraform fmt/validate), and full-suite orchestration via `just test`.

## [0.1.1] - 2026-09-01
### Added
- Added domain names and pricing study document (`docs/domain-names-study.md`).
- Verified WHOIS availability for `raspberyl.md` (and `pezzotta.md`).
- Enriched `docs/REDSTONES.md` with additional red gemstones (Corundum, Pezzottaite/Raspberyl, Taaffeite, Spessartine, Realgar, Vanadinite, Rhodochrosite, Red Zircon/Hyacinth).

## [0.2.0] - 2026-09-01
### Added
- Flutter Desktop / Mobile application scaffold in `app/`.
- Ruby Dark gemstone UI theme (`SpinelTheme`) with `#E0115F` accents and Inter/JetBrains Mono typography.
- `VaultService` for live local filesystem traversal, hierarchical tree scanning, and atomic note saving.
- `DualModeEditor` supporting live Raw Markdown text mode, WYSIWYG Rendered mode, and Split-screen view.
- Floating formatting toolbar for H1-H3, bold, italic, underline, lists, and task checkboxes.
- `FrontmatterDrawer` inspector for visualizing and managing YAML metadata.
- `docs/NAMING_PROPOSAL.md` formalizing Raspberyl / Pezzotta CLI proposal.
- Complete Flutter unit and widget test suite in `app/test/`.
- Conductor Track 1 (`mvp_core_engine_20260901`) marked as completed.

## [0.1.0] - 2026-09-01
### Added
- Monorepo scaffold: `Justfile`, `cli/`, `app/`, `server/`, and `shared/` test fixtures.
- Created `docs/REDSTONES.md` enumerating red gemstones and domain research.
- Implemented `spinel` Go CLI:
  - `spinel init`: Initialize local markdown vaults with git support.
  - `spinel search`: High-speed full-text search with highlighting.
  - `spinel search-frontmatter`: YAML metadata querying (keys, tags, values).
  - `spinel export`: One-click `.tar.gz` archive packaging.
  - `spinel list`: Recursive note enumeration.
- Comprehensive unit test suite with 100% pass rate.
