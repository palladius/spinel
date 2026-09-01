# Specification: Track 1 - Core Markdown Engine, Local Filesystem & Spinel CLI (MVP)

## 1. Overview
Bootstrap the Spinel monorepo structure, build the standalone high-performance Go CLI (`spinel`), and implement the core dual-mode Markdown editing engine and local filesystem vault management in the Flutter desktop client (macOS/Linux).

## 2. Functional Requirements
### 2.1 Monorepo Architecture
- Set up root structure:
  - `cli/`: Go 1.22+ standalone binary (`cmd/spinel`)
  - `app/`: Flutter Desktop application (macOS/Linux)
  - `server/`: Ruby 3.3+ Cloud Run sync API scaffold
  - `shared/`: Shared schemas, test fixtures, and sample markdown vaults

### 2.2 Go CLI Tool (`spinel`)
- `spinel init <vault-path>`: Initialize a new Spinel markdown vault with default template and `.git` configuration.
- `spinel search <query>`: Ultra-fast full-text search across all `.md` files in the vault with highlighted occurrences and line numbers.
- `spinel search-frontmatter <key:value>`: Query YAML frontmatter headers across notes (e.g. `event:work`, `tags:sre`).
- `spinel export --tar <output.tar.gz>`: Package the entire vault into a clean, uncompressed or compressed `.tar.gz` archive.

### 2.3 Flutter Desktop Client (`app/`)
- **Vault Navigator:** Tree-view sidebar displaying folders, subfolders, and `.md` files with live filesystem watcher.
- **Dual-Mode Editor:**
  - Raw Markdown Mode: Syntax-highlighted text editing.
  - WYSIWYG Rendered Mode: Interactive editable rendering for H1-H3, bold, italic, underline, bullet/numbered lists, checkboxes, and image/link embeds.
  - Seamless toggle preserving cursor position and undo/redo state.
- **Frontmatter Inspector:** Dedicated side drawer parsing and rendering YAML metadata properties.

## 3. Non-Functional Requirements
- Instant startup (<200ms) for CLI queries.
- Zero data corruption: atomic file writes (`tempfile` + atomic rename) for all note saves.
- Standalone single static binary for CLI without external runtime dependencies.

## 4. Acceptance Criteria
- [ ] Go CLI tests pass with >80% coverage for search, frontmatter parsing, init, and tar export.
- [ ] Flutter unit and widget tests pass for dual-mode editor state synchronization.
- [ ] Vault modifications on the local filesystem update the editor live without file locks.
- [ ] A sample vault can be created, searched via CLI, edited in GUI, and exported to `.tar.gz`.
