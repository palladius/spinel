# Changelog

All notable changes to the Spinel project will be documented in this file.

## [0.6.0] - 2026-09-18
### Added
- **GitHub Pages Landing Page (`docs/index.html`)**: Ultra-modern, responsive dark-mode landing page designed with obsidian black, deep ruby red, and crimson spinel flame palette inspired by the official logo.
- **Side-by-Side Live Showcase ("Tu che scrivi a sx e vedi il risultato a dx")**: Interactive dual-column engine with an automated typewriter simulating markdown editing on the left and real-time synchronized rendering on the right with interactive checklist toggles.
- **macOS Desktop App Mockup with Interactive Tab Bar**: Realistic window presentation featuring 4 switchable app views (*Live Preview*, *Raw Markdown*, *Cloud Sync Conflict Resolver*, and *Ultra-Dense Vault File Tree*).
- **Core Pillars & Architecture Overview**: Visual breakdowns for Flutter Desktop/Mobile, Standalone Go CLI, Zero-Knowledge AES-256-GCM Cryptography, and Rails 8 Cloud Run backend.
- **Logo & Branding Gallery**: Showcase of official app icon and artistic gemstone variants.
- **Documentation Verification & Tooling**: Added `just serve-docs` and `bin/verify_docs.py` automated asset and markup validator.

## [0.5.0] - 2026-09-18
### Added
- **Cloud Sync UI & Status Indicator**: Live status icons in the navigation bar (Idle, Syncing spinner, Synced checkmark, Amber Conflict alert, Red Error alert).
- **Interactive 2-Pane Conflict Resolution**: Side-by-side visual diff comparison between Local and Remote versions with 3 one-click resolution choices (*Keep Local*, *Accept Remote*, *Keep Both*).
- **Zero-Knowledge Encrypted Sync Engine**: SHA-256 content hashing with client-side AES-256 payload encryption.
- **Custom Brand App Icon**: Obsidian-style faceted ruby shard with Markdown `.md` neon tag badge compiled into native Apple `.icns`.
- **Root README.md**: Complete project documentation, architecture diagram, badges, and quickstart commands.

### Fixed
- **Cursor Hit-Testing & Multi-Line Precision**: Fixed vertical line metric hit-testing in the text editor to eliminate cursor jump desync across lines.
- **Real-Time Live Preview Sync**: Real-time rendering synchronization between the raw markdown editor and the split-screen visual preview pane.

## [0.4.1] - 2026-09-18
### Fixed
- **New Note Creation Dialog**: Fixed silent exit bug where empty title inputs returned without action; extracted robust, testable `NewNoteDialog` widget.
- **Sidebar Header Layout**: Resolved RenderFlex overflow on small window widths using `Expanded` and text ellipsis truncation.

### Added
- **Default Daily Note Title (YYYY-MM-DD)**: Pre-populates note title with current date (`YYYY-MM-DD.md`) pre-selected for instant creation or quick overwrite.
- **Automated Test Coverage**: Added dedicated widget tests in `app/test/new_note_dialog_test.dart`.

## [0.4.0] - 2026-09-07
### Added
- **Dual-Mode Text & WYSIWYG Preview Editor**: Split-pane layout with continuous syntax highlighting and synchronized preview pane.
- **Interactive Slash Commands (`/`)**: Popup menu for heading insertions, bullet lists, code blocks, checklists, and quote formatting.
- **Atomic File Saving**: Scratch tmp buffer writing before safe atomic file replacement preventing partial file writes.

## [0.3.0] - 2026-09-07
### Added
- **Full-Text & Frontmatter Search Engine**: In-memory caching and rapid tokenized grep engine for title, tags, and body.
- **Vault Export CLI (`spinel export`)**: Gzip tarball (.tar.gz) compression packaging for notes and assets.

## [0.2.0] - 2026-09-07
### Added
- **Zero-Knowledge Cryptographic Vault Encryption (`spinel encrypt` / `spinel decrypt`)**: AES-256-GCM authenticated payload encryption.
- **Standalone Go CLI Scaffold**: Flag parsing and cobra architecture.

## [0.1.0] - 2026-09-07
### Added
- **Initial Spinel Workspace Scaffold**: Flutter macOS/iOS app, Go CLI, Rails 8 cloud sync API backend, and Terraform cloud deployment.
