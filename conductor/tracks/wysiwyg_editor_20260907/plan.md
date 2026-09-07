# Implementation Plan: Track 3 - Two-Way Live Preview WYSIWYG Editor

## Phase 1: Markdown AST & Live Preview Span Controller (`app/lib/editor/`)
- [ ] Task: Implement `SpinelLivePreviewController` with dynamic line-aware markdown styling spans
- [ ] Task: Write unit tests for `SpinelLivePreviewController` formatting and caret inspection
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 2: Slash Command Palette Overlay (`app/lib/editor/`)
- [ ] Task: Implement `SlashCommandOverlay` widget with keyboard navigation and block insertion
- [ ] Task: Write widget tests for slash command trigger, selection, and dismissal
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 3: Wikilink `[[` & Tag `#` Autocomplete System (`app/lib/editor/`)
- [ ] Task: Implement `AutocompleteOverlay` with note title and tag fuzzy matching
- [ ] Task: Write widget tests for wikilink popover and insertion
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 4: Integration with DualModeEditor & UI Polish (`app/lib/widgets/`)
- [ ] Task: Integrate `SpinelLivePreviewController`, Slash Command, and Autocomplete into `DualModeEditor`
- [ ] Task: Implement interactive checkbox toggling and callout alert formatting
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 5: End-to-End Verification & Test Suite
- [ ] Task: Write comprehensive end-to-end widget tests in `app/test/wysiwyg_editor_test.dart`
- [ ] Task: Run `just test` across CLI, App, Server, and Infra
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)
