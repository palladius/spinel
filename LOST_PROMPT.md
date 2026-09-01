# 📝 Recovered Prompt: Obsidian Clone Project

> **Origin Workspace:** `nifty-babbage`  
> **Initial Skill / Command:** `/conductor-setup`  
> **Status:** Recovered from input buffer / screenshot

---

## 🎯 Raw Prompt Content

```text
conductor-setup I want to create an obsidian clone which can be synced with NextCloud, git, etc. This needs to be a nice portable app (needs to work on Mac and Linux, you choose the best arch: electron, fluttrer, whatever..) and also needs to be having a mobile version. It needs a user/pass for login, plus some sort of encryption key for the repo (you lose the key, the repo is unusable!). On GCP. Syncs to a GCP DB (you tell me what its best but ask me as i have opinions and im GOOD at this). The UI needs to have a beutiful "MD editor" you can swap from text to rendered and i want to be able to edit BOTH of them. You can strart snall with just H1/2/3 b/i/u and * and - and little other. We can pause the images syncing since this is beside the scope. For 1.0 just pure MD with no other files, then we can build more multimedia ability. of course embedding an image or video from somewhre else will work and it should be beautiful and so on but i dont want to get into the business of syncing images and stuff. Maybe we;ll sync images and ivdeos ELSEWHERE and keep the DB small/ NEeds an export as tar gz and locally it needs to be a REAL filesystem with folders and MD and stuff. you can make assumptions if needed for simplification. I would also love the repo locally to be EASILY git-table. My problem with obsidian is that it can't have a .git so to make it...
```

---

## 📋 Key Requirements Breakdown

1. **Target Platforms:**
   - Desktop: macOS & Linux (portable app: Electron, Flutter, Tauri, etc.)
   - Mobile: Mobile version companion.

2. **Authentication & Security:**
   - User / Password authentication.
   - Zero-knowledge client-side encryption key for the vault/repo (*if key is lost, data is unusable*).

3. **Cloud & Sync Backend:**
   - Hosted on **Google Cloud Platform (GCP)**.
   - Syncs to a GCP database (Cloud SQL, Firestore, Spanner, etc. - to discuss and choose together).
   - Sync compatibility / openness with NextCloud, Git, etc.

4. **Local Storage & Filesystem Architecture:**
   - Real local filesystem directory hierarchy containing standard `.md` markdown files.
   - Easily trackable via Git (`.git` friendly without corruption / proprietary bloat).
   - Export capability as `.tar.gz`.

5. **Markdown Editor (Dual View):**
   - Beautiful Markdown editor with instant toggle between raw text and rendered view.
   - Ability to edit in **both** modes (WYSIWYG rendered mode + raw Markdown mode).
   - Version 1.0 starting scope: Core formatting (`# H1/H2/H3`, `**bold**`, `*italic*`, `_underline_`, `*` / `-` lists).

6. **Media Handling Scope:**
   - **v1.0 Focus:** Pure markdown text files.
   - External embedding for images/videos supported, but heavy binary sync deferred or stored externally to keep the database lightweight.
