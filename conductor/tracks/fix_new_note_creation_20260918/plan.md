# Implementation Plan: Fix New Note Creation & Default Today's Date (YYYY-MM-DD)

Linked GitHub Issue: [#1](https://github.com/palladius/spinel/issues/1)

## Phase 1: TDD & Automated Tests (Red Phase)
- [x] Task: Create automated tests in `app/test/new_note_dialog_test.dart`
  - [x] Test that dialog initializes with today's date formatted as `YYYY-MM-DD` in the title field.
  - [x] Test that tapping "Create Note" creates note `<YYYY-MM-DD>.md` in selected directory without hanging.
  - [x] Test fallback to `YYYY-MM-DD` if title field is cleared.
  - [x] Test custom title creation works properly.
- [x] Task: Run automated tests to confirm Red phase failure.
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 2: Implementation (Green Phase)
- [x] Task: Update `_createNewNoteDialog()` in `app/lib/main.dart` / extract `NewNoteDialog`
  - [x] Pre-populate `titleController` with today's date formatted as `YYYY-MM-DD`.
  - [x] Set selection to select all so user can immediately type a different title if desired.
  - [x] If title is empty, fallback to today's date `YYYY-MM-DD` instead of silent return.
  - [x] Verify note creation, editor selection, and tree refresh.
- [x] Task: Run automated tests to confirm Green phase passing.
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 3: Manual Verification & GitHub Sync
- [x] Task: Run full test suite (`flutter test`).
- [x] Task: Verify end-to-end functionality manually and document evidence.
- [x] Task: Comment on GitHub Issue #1 with resolution summary and status.
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md)
