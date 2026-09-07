# Specification: Track 3 - Two-Way Live Preview WYSIWYG Editor

## 1. Overview
Deliver an Obsidian/Notion-grade hybrid Markdown editing experience for Spinel:
- **Live Preview:** Hybrid syntax styling where markdown tokens (`#`, `**`, `*`, `~~`, ```` `) are visually rendered in-place when the cursor is away, and expanded for direct inline editing when the cursor enters the line.
- **Slash Menu (`/`):** Contextual popup for inserting blocks (H1-H3, tasks, code blocks, quotes, callouts, tables, dividers).
- **Wikilink & Tag Autocomplete:** Fast keyboard autocompletion for `[[Note Title]]` and `#tag`.
- **Interactive Checklist Elements:** Direct toggle of `- [ ]` / `- [x]` with immediate synchronization.

## 2. Functional Requirements
### 2.1 Live Preview Span Controller (`app/lib/editor/live_preview_controller.dart`)
- Custom `TextEditingController` extending text span generation:
  - Detects current line of cursor selection.
  - For non-active lines, styles Headings (large font), Bold, Italic, Strikethrough, Code spans, Blockquotes, and Callouts without visual clutter.
  - For active lines containing the caret, shows full raw markdown syntax with syntax highlighting.
  - Maintains exact 1:1 character index synchronization so typing, deleting, and undo/redo operate flawlessly.

### 2.2 Slash Command Overlay (`app/lib/editor/slash_command_overlay.dart`)
- Listens to `/` input at beginning of line or after whitespace.
- Displays popup with options: Heading 1, Heading 2, Heading 3, Task List, Bullet List, Code Block, Blockquote, Callout Note, Divider.
- Supports keyboard navigation: ArrowUp, ArrowDown, Enter (select), Escape (dismiss).

### 2.3 Wikilink & Tag Autocompleter (`app/lib/editor/autocomplete_overlay.dart`)
- Typing `[[` triggers dropdown filtering all markdown note titles in current vault.
- Typing `#` triggers dropdown filtering existing tags.
- Selecting an entry inserts `[[Selected Note]]` or `#selected_tag`.

### 2.4 Visual Polish & Dual-Mode Integration (`app/lib/widgets/dual_mode_editor.dart`)
- Single unified document buffer shared across Raw, Split, and Live Preview modes.
- Instant, zero-lag tab transitions.

## 3. Acceptance Criteria
- [ ] `SpinelLivePreviewController` correctly formats markdown spans while maintaining exact raw text buffer.
- [ ] Typing `/` opens slash command overlay; selecting an option replaces `/` with the chosen markdown block.
- [ ] Typing `[[` shows vault notes and inserts completed wikilink.
- [ ] Clicking checkboxes in Visual mode updates underlying document and triggers save state.
- [ ] Widget test suite in `app/test/wysiwyg_editor_test.dart` passes 100%.
