# Implementation Plan: Fix New Note Creation & Default Today's Date (YYYY-MM-DD)

Linked GitHub Issue: [#1](https://github.com/palladius/spinel/issues/1)

## Phase 1: TDD & Automated Tests (Red Phase)
- [ ] Task: Create automated tests in `app/test/new_note_dialog_test.dart`
  - [ ] Test that dialog initializes with today's date formatted as `YYYY-MM-DD` in the title field.
  - [ ] Test that tapping "Create Note" creates note `<YYYY-MM-DD>.md` in selected directory without hanging.
  - [ ] Test fallback to `YYYY-MM-DD` if title field is cleared.
  - [ ] Test custom title creation works properly.
- [ ] Task: Run automated tests to confirm Red phase failure.
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 2: Implementation (Green Phase)
- [ ] Task: Update `_createNewNoteDialog()` in `app/lib/main.dart`
  - [ ] Pre-populate `titleController` with today's date formatted as `YYYY-MM-DD`.
  - [ ] Set selection to select all so user can immediately type a different title if desired.
  - [ ] If title is empty, fallback to today's date `YYYY-MM-DD` instead of silent return.
  - [ ] Verify note creation, editor selection, and tree refresh.
- [ ] Task: Run automated tests to confirm Green phase passing.
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 3: Manual Verification & GitHub Sync
- [ ] Task: Run full test suite (`flutter test`).
- [ ] Task: Verify end-to-end functionality manually and document evidence.
- [ ] Task: Comment on GitHub Issue #1 with resolution summary and status.
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)
