package sync

import (
	"bytes"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"net/http"
	"path/filepath"
	"time"

	"github.com/palladius/spinel/cli/pkg/crypto"
	"github.com/palladius/spinel/cli/pkg/vault"
)

type NoteDelta struct {
	RelativePath  string                 `json:"relative_path"`
	EncryptedBody string                 `json:"encrypted_body"`
	Frontmatter   map[string]interface{} `json:"frontmatter"`
	ContentHash   string                 `json:"content_hash"`
	Deleted       bool                   `json:"deleted"`
}

type SyncRequest struct {
	Since  *string     `json:"since"`
	Deltas []NoteDelta `json:"deltas"`
}

type ServerDelta struct {
	ID            string                 `json:"id"`
	RelativePath  string                 `json:"relative_path"`
	EncryptedBody string                 `json:"encrypted_body"`
	Frontmatter   map[string]interface{} `json:"frontmatter"`
	ContentHash   string                 `json:"content_hash"`
	Version       int                    `json:"version"`
	Deleted       bool                   `json:"deleted"`
	UpdatedAt     string                 `json:"updated_at"`
}

type SyncResponse struct {
	SyncedAt     string        `json:"synced_at"`
	AppliedCount int           `json:"applied_count"`
	ServerDeltas []ServerDelta `json:"server_deltas"`
}

// ComputeHash returns SHA-256 hex string of content.
func ComputeHash(content string) string {
	h := sha256.Sum256([]byte(content))
	return hex.EncodeToString(h[:])
}

// PerformSync synchronizes local vault with remote Rails sync API.
func PerformSync(vaultPath, remoteURL, apiToken, passphrase string) (*SyncResponse, error) {
	key := crypto.DeriveKey(passphrase)

	notes, err := vault.Walk(vaultPath)
	if err != nil {
		return nil, fmt.Errorf("failed to scan local vault: %w", err)
	}

	var deltas []NoteDelta
	for _, n := range notes {
		encBody, err := crypto.Encrypt([]byte(n.Doc.Body), key)
		if err != nil {
			return nil, fmt.Errorf("failed to encrypt %s: %w", n.RelativePath, err)
		}
		deltas = append(deltas, NoteDelta{
			RelativePath:  n.RelativePath,
			EncryptedBody: encBody,
			Frontmatter:   n.Doc.Frontmatter,
			ContentHash:   ComputeHash(n.Doc.Raw),
			Deleted:       false,
		})
	}

	reqBody := SyncRequest{
		Since:  nil,
		Deltas: deltas,
	}

	payloadBytes, err := json.Marshal(reqBody)
	if err != nil {
		return nil, err
	}

	url := fmt.Sprintf("%s/api/v1/sync/delta", remoteURL)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(payloadBytes))
	if err != nil {
		return nil, err
	}

	req.Header.Set("Authorization", "Bearer "+apiToken)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 15 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("sync HTTP request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("server responded with status %d", resp.StatusCode)
	}

	var syncResp SyncResponse
	if err := json.NewDecoder(resp.Body).Decode(&syncResp); err != nil {
		return nil, fmt.Errorf("failed to decode response: %w", err)
	}

	// Apply server deltas to local disk
	for _, sd := range syncResp.ServerDeltas {
		fullPath := filepath.Join(vaultPath, sd.RelativePath)
		if sd.Deleted {
			// Handle local deletion if needed
			continue
		}

		decryptedBody, err := crypto.Decrypt(sd.EncryptedBody, key)
		if err != nil {
			// Skip if decrypt fails (different key)
			continue
		}

		// Reconstruct file with frontmatter and body
		doc := vault.Note{
			Path: fullPath,
		}
		_ = doc
		rawNote := string(decryptedBody)
		_ = vault.WriteAtomic(fullPath, rawNote)
	}

	return &syncResp, nil
}
