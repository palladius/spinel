# Product Guidelines: Spinel (spinel.md)

## 🎨 Visual Identity & Theme
- **Color Palette (Spinel Dark Aesthetic):**
  - Primary Base: Deep obsidian black (`#0F0F12` / `#16161A`).
  - Accent / Brand: Radiant spinel crimson red (`#E0115F` / `#D81159`).
  - Secondary Accents: Warm slate gray (`#94A1B2`) and crisp foreground white (`#FFFFFE`).
- **Typography:**
  - UI & Headings: Modern Sans-Serif (`Inter` / system font).
  - Editor & Code: Clean Monospace (`JetBrains Mono` / `Fira Code`).

## 🖱️ Editor UX & Interaction Model
- **Interaction Style:** Mouse & toolbar-centric UX with contextual discoverability.
  - **Floating Formatting Toolbar:** Appears seamlessly upon text selection with quick actions for Bold (`**`), Italic (`*`), Underline (`_`), Heading levels (H1-H3), Lists (`*` / `-`), and Links.
  - **Contextual Sidebars:** Collapsible file tree sidebar (with folder organization, note creation, `.tar.gz` export), Frontmatter Inspector sidebar, and Git / Sync status indicator.
  - **Dual-Mode Toggle:** Floating / toolbar switch to toggle seamlessly between Raw Markdown and WYSIWYG Rendered mode, supporting live editing in both.

## 💻 CLI UX (`spinel`)
- **Visuals & Tone:** Rich, engaging, colorful terminal output with emojis (🪵, 💎, 🚀, 🔍), spinners, and clean progress indicators.
- **Output Formats:** Default formatted human-readable colored tables, with `--json`, `--yaml`, and `--plain` flags for easy piping and scripting.
- **Subcommands:** Intuitive naming (`spinel search <query>`, `spinel search-frontmatter <key:val>`, `spinel sync`, `spinel backup`, `spinel export`).

## 🛡️ Security & Privacy Guardrails
- **Zero-Knowledge Principle:** Clear visual cues when a vault is encrypted/locked. No plaintext content or unencrypted keys are ever transmitted over the wire or stored in cloud logs.
