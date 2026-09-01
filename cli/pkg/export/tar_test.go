package export

import (
	"archive/tar"
	"compress/gzip"
	"io"
	"os"
	"path/filepath"
	"testing"

	"github.com/palladius/spinel/cli/pkg/vault"
)

func TestVaultToTarGz(t *testing.T) {
	tempDir, err := os.MkdirTemp("", "spinel-tar-src-*")
	if err != nil {
		t.Fatalf("failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tempDir)

	_ = vault.Init(tempDir, "ExportVault")
	_ = vault.WriteAtomic(filepath.Join(tempDir, "01_Daily_Notes", "sample.md"), "# Daily Note\nExport test content")

	outTar := filepath.Join(tempDir, "backup.tar.gz")
	err = VaultToTarGz(tempDir, outTar)
	if err != nil {
		t.Fatalf("VaultToTarGz failed: %v", err)
	}

	// Verify tar content
	f, err := os.Open(outTar)
	if err != nil {
		t.Fatalf("failed to open exported tar: %v", err)
	}
	defer f.Close()

	gr, err := gzip.NewReader(f)
	if err != nil {
		t.Fatalf("failed to create gzip reader: %v", err)
	}
	defer gr.Close()

	tr := tar.NewReader(gr)
	foundSample := false
	for {
		hdr, err := tr.Next()
		if err == io.EOF {
			break
		}
		if err != nil {
			t.Fatalf("tar read error: %v", err)
		}
		if hdr.Name == "01_Daily_Notes/sample.md" {
			foundSample = true
		}
	}

	if !foundSample {
		t.Errorf("expected to find 01_Daily_Notes/sample.md in exported tar archive")
	}
}
