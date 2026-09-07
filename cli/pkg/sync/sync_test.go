package sync

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"

	"github.com/palladius/spinel/cli/pkg/crypto"
	"github.com/palladius/spinel/cli/pkg/vault"
)

func TestPerformSync(t *testing.T) {
	tempDir, err := os.MkdirTemp("", "spinel-sync-test-*")
	if err != nil {
		t.Fatalf("temp dir error: %v", err)
	}
	defer os.RemoveAll(tempDir)

	_ = vault.Init(tempDir, "SyncTestVault")
	_ = vault.WriteAtomic(filepath.Join(tempDir, "01_Daily_Notes", "note.md"), "# Daily Note\nLocal content to sync")

	passphrase := "secret_key_pass"
	key := crypto.DeriveKey(passphrase)
	encSample, _ := crypto.Encrypt([]byte("# Server Note\nRemote content pulled from cloud"), key)

	// Mock server
	mockServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("Authorization") != "Bearer test_token" {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}

		resp := SyncResponse{
			SyncedAt:     "2026-09-02T16:00:00Z",
			AppliedCount: 1,
			ServerDeltas: []ServerDelta{
				{
					ID:            "uuid-1",
					RelativePath:  "02_Projects/server_note.md",
					EncryptedBody: encSample,
					ContentHash:   "hash_remote",
					Version:       1,
					Deleted:       false,
					UpdatedAt:     "2026-09-02T16:00:00Z",
				},
			},
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(resp)
	}))
	defer mockServer.Close()

	syncResp, err := PerformSync(tempDir, mockServer.URL, "test_token", passphrase)
	if err != nil {
		t.Fatalf("PerformSync failed: %v", err)
	}

	if syncResp.AppliedCount != 1 {
		t.Errorf("expected applied_count 1, got %d", syncResp.AppliedCount)
	}

	// Verify remote note pulled and decrypted locally
	downloadedPath := filepath.Join(tempDir, "02_Projects", "server_note.md")
	content, err := os.ReadFile(downloadedPath)
	if err != nil {
		t.Fatalf("failed to read downloaded note: %v", err)
	}

	if string(content) != "# Server Note\nRemote content pulled from cloud" {
		t.Errorf("unexpected content: %s", string(content))
	}
}
