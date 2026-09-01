package vault

import (
	"os"
	"path/filepath"
	"testing"
)

func TestVaultInitAndWalk(t *testing.T) {
	tempDir, err := os.MkdirTemp("", "spinel-vault-test-*")
	if err != nil {
		t.Fatalf("failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tempDir)

	err = Init(tempDir, "TestVault")
	if err != nil {
		t.Fatalf("Init failed: %v", err)
	}

	// Verify folders created
	for _, sub := range []string{"01_Daily_Notes", "02_Projects", "03_Resources", ".spinel"} {
		p := filepath.Join(tempDir, sub)
		if fi, err := os.Stat(p); err != nil || !fi.IsDir() {
			t.Errorf("expected dir %s to exist", p)
		}
	}

	// Create test note with atomic write
	notePath := filepath.Join(tempDir, "01_Daily_Notes", "today.md")
	content := "---\ntags: [test]\nauthor: Alice\n---\n# Today\nHello world!"
	if err := WriteAtomic(notePath, content); err != nil {
		t.Fatalf("WriteAtomic failed: %v", err)
	}

	notes, err := Walk(tempDir)
	if err != nil {
		t.Fatalf("Walk failed: %v", err)
	}

	found := false
	for _, n := range notes {
		if n.RelativePath == "01_Daily_Notes/today.md" || n.RelativePath == filepath.Join("01_Daily_Notes", "today.md") {
			found = true
			if !n.Doc.MatchQuery("author", "Alice") {
				t.Errorf("expected note to match author:Alice")
			}
		}
	}
	if !found {
		t.Errorf("expected to find 01_Daily_Notes/today.md in walk results")
	}
}
