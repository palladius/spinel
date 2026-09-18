# Implementation Plan: Track 4 - Spinel Landing Page for GitHub Pages

## Phase 1: Foundation, Palette & Hero Section (`docs/`)
- [x] Task: Create `docs/index.html` structure with Tailwind CSS, custom dark-black base and deep ruby/crimson spinel theme tokens (c41ede7)
- [x] Task: Build top navigation bar with Spinel logo, navigation links, GitHub badge and repository star count (c41ede7)
- [x] Task: Build Hero section with glowing spinel gemstone effects, title, punchline, and primary CTAs (c41ede7)
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 2: macOS App Mockup & Interactive Tab Switcher (`docs/`)
- [x] Task: Implement realistic macOS window container with traffic lights and interactive tab bar (Live Preview, Raw Markdown, Cloud Sync, Vault Tree) (c41ede7)
- [x] Task: Build view states and mockups for each tab with callout tooltips highlighting key features (c41ede7)
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 3: Interactive Side-by-Side Dual-Mode Showcase (`docs/`)
- [x] Task: Implement side-by-side interactive split editor container (Left: Editor, Right: Live Render) (c41ede7)
- [x] Task: Implement typewriter JavaScript engine simulating typing of markdown note with YAML frontmatter, tags, wikilinks, and checkboxes (c41ede7)
- [x] Task: Implement live synchronized markdown rendering on right pane with interactive checklist toggling and manual typing support (c41ede7)
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 4: Architecture, Feature Grid, Logo Gallery & Quickstart (`docs/`)
- [x] Task: Build 4-pillar architectural cards (Flutter Desktop/Mobile, Standalone Go CLI, Zero-Knowledge AES-256-GCM, Cloud Run + Cloud SQL Rails 8) (c41ede7)
- [x] Task: Add logo showcase section displaying official icon and variants (c41ede7)
- [x] Task: Add interactive terminal quickstart with copy-to-clipboard functionality (`spinel` and `just` commands) (c41ede7)
- [x] Task: Add footer with project links, license, and GitHub repo links (c41ede7)
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 5: Tooling, Local Preview Recipe & Verification
- [x] Task: Add `serve-docs` recipe to `Justfile` to preview GitHub Pages locally (c41ede7)
- [x] Task: Add automated link/asset verification test script to ensure all images and links in `docs/index.html` exist (c41ede7)
- [x] Task: Run full tests (`just test`) and verify docs server (c41ede7)
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md)
