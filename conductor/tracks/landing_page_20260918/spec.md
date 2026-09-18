# Specification: Track 4 - Spinel Landing Page for GitHub Pages

## 1. Overview
Creare una landing page "strafiga", ultra-moderna, responsive e dark-mode first per Spinel (`spinel.md`) ospitata su GitHub Pages (`docs/index.html`). La pagina valorizza il nuovo logo ufficiale di Spinel, chiarisce la proposizione "local-first & zero-knowledge", e implementa una palette cromatica d'eccellenza basata su nero profondo, ossidiana e varie gradazioni di rosso rubino / crimson / spinel flame ispirate dal logo.

Offre una duplice esperienza visiva interattiva:
1. **Pannello Mockup Reale / Screenshot App**: un frame macOS elegante con switcher di tab (Live Preview, Raw Markdown, Cloud Sync, Vault Tree) che mostra la reale interfaccia grafica di Spinel.
2. **Showcase Side-by-Side Interattivo**: a sinistra finestra editor con digitazione animata typewriter (markdown, frontmatter YAML, tag, wikilink, checklist) e a destra il rispettivo rendering live perfettamente sincronizzato.

## 2. Functional Requirements
### 2.1 Hero & Branding
- Header con logo ufficiale Spinel (`docs/assets/spinel_icon.png`), menu di navigazione fluido (Features, App Preview, Architecture, CLI, GitHub).
- Badge dinamici (Build passing, License MIT, Flutter, Go, Rails 8, GCP Terraform).
- Hero headline d'impatto con call-to-action primarie ("Star on GitHub", "Explore Quickstart", "Download").
- Glow effects rubino/spinel flame su sfondo nero ossidiana (`#0a0a0c`, `#131118`, `#800020`, `#9b111e`, `#e11d48`, `#be123c`, `#4a0404`).

### 2.2 App Mockup & macOS Tab Switcher
- Finestra macOS stilizzata (pulsanti window traffic lights rosso/giallo/verde) con tab switcher interattivo:
  - *Tab 1: Live Preview Editor*
  - *Tab 2: Raw Markdown & Frontmatter*
  - *Tab 3: Cloud Sync & Conflict Resolver*
  - *Tab 4: Vault File Tree & Badges*
- Presentazione visiva fotorealistica / screenshot dell'app per ogni tab con indicatori callout delle feature chiave.

### 2.3 Interactive Side-by-Side Dual-Mode Showcase ("Tu che scrivi a sx e vedi il risultato a dx")
- Finestra split-pane interattiva:
  - **Sinistra (Editor)**: Digitazione animata typewriter di markdown (`# Note`, tags `#work`, frontmatter YAML, wikilink `[[Architectural Decisions]]`, checklist `- [x]`).
  - **Destra (Live Preview)**: Render real-time sincronizzato che trasforma dinamicamente il testo in componenti formattati, badge colorati e checkbox cliccabili.
  - Possibilità di pausare l'animazione o scrivere liberamente nell'editor a sinistra per testare l'anteprima in tempo reale.

### 2.4 Architecture & Core Pillars Section
- Spiegazione visuale dei 4 pilastri:
  1. **Desktop & Mobile App**: Flutter con dual-mode WYSIWYG & SQLite local cache.
  2. **Go CLI (`spinel`)**: Tool istantaneo da terminale per ricerca full-text e export tar.gz.
  3. **Zero-Knowledge Sync**: Crittografia AES-256-GCM lato client.
  4. **Cloud Run + Cloud SQL Backend**: Rails 8 con tabelle PostgreSQL JSONB & pgvector.
- Galleria delle varianti del logo (`docs/assets/spinel_icon_variant_*.jpg`).

### 2.5 Quickstart & Justfile Integration
- Blocco comandi da terminale con supporto "Copy to clipboard" per i comandi `just` e CLI `spinel`.
- Ricetta `serve-docs` in `Justfile` per lanciare un server HTTP locale rapido (`python3 -m http.server 8000 --directory docs`).

## 3. Acceptance Criteria
- [ ] `docs/index.html` contiene la landing page responsive completa funzionante in GitHub Pages.
- [ ] La palette cromatica rispetta i requisiti: base nero profondo/ossidiana e varie scale di rosso/rubino come da logo.
- [ ] La barra superiore integra il logo ufficiale Spinel con link corretti.
- [ ] Il mockup macOS include tab interattivi funzionanti che cambiano viste dell'app.
- [ ] L'effetto typewriter side-by-side digita il markdown a sinistra e renderizza in tempo reale a destra.
- [ ] La ricetta `just serve-docs` permette di visualizzare la pagina localmente su porta 8000.
