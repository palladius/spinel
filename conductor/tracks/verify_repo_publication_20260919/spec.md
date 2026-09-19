# Specification: Verifica PUBBLICAZIONE di un GH repo privato

## 1. Overview
Esecuzione di un'audit approfondito di sicurezza, privacy e igiene del repository prima di trasformare  da privato a pubblico su GitHub.

## 2. Functional & Security Requirements
- [x] Scansione completa della cronologia Git per credenziali, token, chiavi SSH, certificati PEM o password in chiaro.
- [x] Verifica dell'assenza di file , file di configurazione privati o secret master key.
- [x] Verifica dei file cancellati nella storia di git (commit mode delete).
- [x] Ispezione di tutte le GitHub Issues e Pull Request esistenti.
- [x] Verifica dei file di infrastruttura Terraform () per accertare l'assenza di ID di progetto hardcoded, password fisse o credenziali statiche.
- [x] Ispezione degli indirizzi email e dei riferimenti a risorse interne/corporate.

## 3. Acceptance Criteria
- Nessun segreto, token API o chiave privata presente nel working tree o nella storia Git.
- Repository pronto e sicuro per la pubblicazione su GitHub e attivazione di GitHub Pages.
