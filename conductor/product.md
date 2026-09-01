# Product Definition: Spinel (spinel.md)

A high-performance, privacy-first, cross-platform Markdown knowledge base and Obsidian alternative designed for engineers, SREs, and knowledge workers.

## Vision & Core Objectives
- **Local-First & Direct Filesystem:** Operates directly on a real local directory hierarchy of standard `.md` markdown files.
- **Native Git-Friendly Architecture:** First-class `.git` support without proprietary folder baggage or corruption.
- **Zero-Knowledge Security:** Client-side AES-256-GCM encryption with passphrase-derived keys (Argon2id). Remote Git mirrors (GitHub/GitLab) and cloud backups are encrypted before leaving the client.
- **Dual-Mode Markdown Editor:** Seamless toggle and simultaneous editing support between raw Markdown text and rich rendered WYSIWYG mode (v1.0 focusing on H1-H3, bold, italic, underline, lists, checkboxes, and external media embeds).
- **Point-in-Time History (Time Machine) & Daily Backups:** Automated daily snapshots, Git commit history navigation, and one-click rollback to any historical point in time.
- **First-Class Fast CLI from Day 1 (`spinel`):** Lightning-fast command-line interface for querying notes, full-text search, and structured frontmatter filtering (e.g., `spinel search Riccardo`, `spinel search-frontmatter event:work`).
- **GCP Cloud Synchronization:** Fast delta synchronization against Google Cloud SQL (PostgreSQL) utilizing JSONB for structured YAML frontmatter indexing.
- **Portability & NextCloud Sync:** One-click `.tar.gz` archive export and NextCloud / WebDAV / Git remote compatibility.

## Target Platforms & Components
- **Desktop Client:** macOS & Linux (via Flutter Desktop)
- **Mobile Client:** iOS & Android companion client (via Flutter Mobile)
- **CLI Utility:** `spinel` standalone executable in Go for power users and automation
- **Cloud Backend:** Ruby 3.3+ Cloud Run service connected to Google Cloud SQL (PostgreSQL)
