# Implementation Plan: Track 1 - Core Markdown Engine, Local Filesystem & Spinel CLI (MVP)

## Phase 1: Monorepo Scaffolding & Shared Infrastructure
- [x] Task: Set up root monorepo layout (`cli/`, `app/`, `server/`, `shared/`) with root `Justfile`
- [x] Task: Create sample test vault fixture with nested folders, YAML frontmatters, and markdown content
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 2: Go CLI Engine (`cli/`) with TDD
- [x] Task: Write unit tests for vault initialization, filesystem traversal, and atomic write operations
- [x] Task: Implement `spinel init` command with default vault templates and `.gitignore` setup
- [x] Task: Write unit tests for YAML frontmatter parser and query matcher (`search-frontmatter`)
- [x] Task: Implement frontmatter indexing and search logic
- [x] Task: Write unit tests for full-text search engine with colorized CLI output
- [x] Task: Implement `spinel search` and `spinel export --tar` archive packager
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 3: Flutter Vault Filesystem Engine (`app/`)
- [ ] Task: Write unit and widget tests for local filesystem vault manager and file tree state
- [ ] Task: Implement reactive file tree sidebar with live directory watching
- [ ] Task: Write tests for YAML frontmatter extraction and state inspector
- [ ] Task: Implement Frontmatter Inspector side drawer in Flutter
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 4: Dual-Mode Markdown Editor (`app/`)
- [ ] Task: Write tests for Markdown document state synchronization between Raw text and AST nodes
- [ ] Task: Implement Raw Markdown Mode with syntax highlighting and line numbers
- [ ] Task: Implement WYSIWYG Rendered Mode for H1-H3, bold, italic, underline, lists, checkboxes, and embeds
- [ ] Task: Implement floating formatting toolbar and seamless dual-mode toggle switch
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 5: End-to-End Integration & CLI Verification
- [ ] Task: Test end-to-end integration: initialize vault with CLI, edit in GUI, search in CLI, and export `.tar.gz`
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)
