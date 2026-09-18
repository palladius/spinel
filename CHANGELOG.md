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

## [0.4.0] - 2026-09-07
### Added
- **Obsidian-Style Live Preview Engine (`SpinelLivePreviewController`)**: Dynamic hybrid markdown controller that renders rich headings, bold, italic, monospace chips, wikilinks, and tags while revealing raw tokens for precision editing on the active cursor line.
- **Notion-Style Slash Command Menu (`SlashCommandMenu`)**: Floating command overlay triggered by `/` with keyboard navigation for inserting Headings (H1–H3), To-do lists, Code blocks, Blockquotes, Callout alerts, and Dividers.
- **Wikilink `[[` & Tag `#` Autocompleter (`AutocompleteOverlay`)**: Contextual popovers fuzzy-matching vault note titles and frontmatter tags.
- **Floating Formatting Toolbar**: Quick actions for bold, italic, underline, strikethrough, lists, task checkboxes, code, and links.
- **Widget Test Suite (`wysiwyg_editor_test.dart`)**: 100% automated coverage for live preview spans, slash commands, and wikilink autocompletions.

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
