# Technology Stack: Spinel (spinel.md)

## 1. Client Applications (Desktop & Mobile)
- **Framework:** Flutter 3.x (macOS, Linux Desktop, iOS, Android Mobile)
- **State Management:** Riverpod / Bloc
- **Markdown & Editor Engine:** Custom Dual-Mode Controller combining `flutter_markdown` AST parser & rich text editable span controller
- **Local Cache & Indexing:** Direct raw `.md` filesystem storage + SQLite (via Drift) for instant local queries and frontmatter cache
- **Crypto & Security:** AES-256-GCM + Argon2id key derivation (`cryptography` package)

## 2. CLI Power Tool (`spinel`)
- **Language:** Go 1.22+
- **CLI Framework:** `spf13/cobra` (Commands & flags), `charmbracelet/bubbletea` / `lipgloss` (Rich colorful terminal UI, emojis, tables)
- **Distribution:** Single static binary with zero runtime dependencies (Mac arm64/x86_64, Linux)

## 3. Backend Cloud API
- **Language & Runtime:** Ruby 3.3+ on Google Cloud Run
- **Framework:** Sinatra / Hanami lightweight REST / GraphQL API with `sequel` / `pg` gem
- **Containerization:** Docker multi-stage build, minimal Alpine / Debian-slim image

## 4. Cloud Infrastructure & Storage (GCP)
- **Database:** Google Cloud SQL for PostgreSQL 16+
  - Native `JSONB` with GIN indexing for YAML frontmatter key/value querying
  - `pgvector` extension for semantic search and embeddings
- **Hosting & Compute:** Google Cloud Run (Serverless, auto-scaling to zero)
- **Backup & Time Machine:** Automated Cloud SQL daily snapshots + client-side encrypted Git bundle mirrors
