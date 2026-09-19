# Changelog

All notable changes to the Spinel project will be documented in this file.

## [0.4.1] - 2026-09-18
### Fixed
- **New Note Creation Dialog**: Fixed silent exit bug where empty title inputs returned without action; extracted robust, testable `NewNoteDialog` widget.
- **Sidebar Header Layout**: Resolved RenderFlex overflow on small window widths using `Expanded` and text ellipsis truncation.

### Added
- **Default Daily Note Title (YYYY-MM-DD)**: Pre-populates note title with current date (`YYYY-MM-DD.md`) pre-selected for instant creation or quick overwrite.
- **Automated Test Coverage**: Added dedicated widget tests in `app/test/new_note_dialog_test.dart`.

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
