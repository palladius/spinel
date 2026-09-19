# Specification: Fix New Note Creation & Default Today's Date (YYYY-MM-DD)

## 1. Overview
Risoluzione del bug nel dialog "Create New Note" di Spinel dove il clic su "Create Note" non produceva alcun effetto se il campo titolo era vuoto. Implementazione della mini feature per cui il titolo viene pre-popolato di default con la data odierna (`YYYY-MM-DD`), permettendo la creazione immediata con un solo clic oltre alla personalizzazione del titolo.

## 2. Root Cause Analysis (RCA)
Nel file `app/lib/main.dart` all'interno del metodo `_createNewNoteDialog()`:
- `titleController.text` è inizialmente vuoto (`""`).
- Nel callback `ElevatedButton.onPressed`:
  ```dart
  final title = titleController.text.trim();
  if (title.isEmpty) return; // Silent early return!
  ```
  Se l'utente apre il dialog e clicca subito sul secondo bottone "Create Note", il titolo è vuoto, il listener esegue una `return` silente senza mostrare errori né creare il file né chiudere il dialog.

## 3. Functional Requirements
1. **Pre-popolamento Data Odierna**: All'apertura del dialog `_createNewNoteDialog()`, il controller del titolo viene pre-popolato con la data odierna formattata `YYYY-MM-DD` (es. `2026-09-18`), con selezione del testo completa per facilitare sovrascrittura rapida.
2. **Fallback Titolo Vuoto**: Se l'utente cancella completamente il testo e preme "Create Note", il sistema usa come fallback la data odierna `YYYY-MM-DD` invece di fallire silenziosamente.
3. **Cartella di default intelligente**: Se una nota è selezionata, usa la sua directory genitore; altrimenti se esiste una cartella `01_Daily_Notes` usa quella; altrimenti Root (`/ (Root)`).
4. **Creazione File e Selezione Immediata**:
   - Genera il file con formato `<title_sanitized>.md` (o `YYYY-MM-DD.md` nel caso di data).
   - Crea il file su disco con frontmatter standard.
   - Chiude il dialog (`Navigator.pop(ctx)`).
   - Invalida il provider dell'albero dei file (`ref.invalidate(vaultNodesProvider)`) e seleziona la nota creata nell'editor.

## 4. Acceptance Criteria
- Aprendo il dialog "Create New Note", il campo titolo contiene la data di oggi (`YYYY-MM-DD`).
- Cliccando su "Create Note" (il secondo bottone), il file viene creato su disco nella cartella indicata e aperto nell'editor.
- Se l'utente modifica il titolo (es. `SRE Architecture`), viene creato `sre_architecture.md`.
- Test automatici widget e unit test passanti al 100%.

## 5. Linked GitHub Issue
- [Issue #1: BUG: Create New Note button does nothing + Default YYYY-MM-DD title](https://github.com/palladius/spinel/issues/1)
