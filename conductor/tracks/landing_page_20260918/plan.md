# Implementation Plan: Track 4 - Spinel Landing Page for GitHub Pages

## Phase 1: Foundation, Palette & Hero Section (`docs/`)
- [ ] Task: Create `docs/index.html` structure with Tailwind CSS, custom dark-black base and deep ruby/crimson spinel theme tokens
- [ ] Task: Build top navigation bar with Spinel logo, navigation links, GitHub badge and repository star count
- [ ] Task: Build Hero section with glowing spinel gemstone effects, title, punchline, and primary CTAs
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 2: macOS App Mockup & Interactive Tab Switcher (`docs/`)
- [ ] Task: Implement realistic macOS window container with traffic lights and interactive tab bar (Live Preview, Raw Markdown, Cloud Sync, Vault Tree)
- [ ] Task: Build view states and mockups for each tab with callout tooltips highlighting key features
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 3: Interactive Side-by-Side Dual-Mode Showcase (`docs/`)
- [ ] Task: Implement side-by-side interactive split editor container (Left: Editor, Right: Live Render)
- [ ] Task: Implement typewriter JavaScript engine simulating typing of markdown note with YAML frontmatter, tags, wikilinks, and checkboxes
- [ ] Task: Implement live synchronized markdown rendering on right pane with interactive checklist toggling and manual typing support
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 4: Architecture, Feature Grid, Logo Gallery & Quickstart (`docs/`)
- [ ] Task: Build 4-pillar architectural cards (Flutter Desktop/Mobile, Standalone Go CLI, Zero-Knowledge AES-256-GCM, Cloud Run + Cloud SQL Rails 8)
- [ ] Task: Add logo showcase section displaying official icon and variants
- [ ] Task: Add interactive terminal quickstart with copy-to-clipboard functionality (`spinel` and `just` commands)
- [ ] Task: Add footer with project links, license, and GitHub repo links
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 5: Tooling, Local Preview Recipe & Verification
- [ ] Task: Add `serve-docs` recipe to `Justfile` to preview GitHub Pages locally
- [ ] Task: Add automated link/asset verification test script to ensure all images and links in `docs/index.html` exist
- [ ] Task: Run full tests (`just test`) and verify docs server
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)
