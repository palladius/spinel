---
title: "Project A Architecture"
tags: ["architecture", "gcp", "cloudsql"]
category: "spec"
author: "RiccardinoCM26"
---

# Project A: Cloud Sync Engine

## Overview
Spinel syncs local `.md` files to a **Google Cloud SQL (PostgreSQL)** backend utilizing `JSONB` for YAML frontmatter indexing.

- Real filesystem directory structure.
- Native `.git` repository integration.
- Client-side zero-knowledge encryption with AES-256-GCM.
