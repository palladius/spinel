# Changelog

All notable changes to the Spinel project will be documented in this file.

## [0.1.1] - 2026-09-01
### Added
- Added domain names and pricing study document (`docs/domain-names-study.md`).
- Enriched `docs/REDSTONES.md` with additional red gemstones (Corundum, Pezzottaite, Taaffeite, Spessartine, Realgar, Vanadinite, Rhodochrosite, Red Zircon/Hyacinth).

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
