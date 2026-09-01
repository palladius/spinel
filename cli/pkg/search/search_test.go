package search

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/palladius/spinel/cli/pkg/vault"
)

func TestFullTextAndFrontmatterSearch(t *testing.T) {
	tempDir, err := os.MkdirTemp("", "spinel-search-test-*")
	if err != nil {
		t.Fatalf("failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tempDir)

	_ = vault.Init(tempDir, "SearchVault")

	note1 := filepath.Join(tempDir, "01_Daily_Notes", "note1.md")
	content1 := "---\ntitle: SRE Incident\nservice: CloudSQL\ntags: [sre, postgres]\n---\n# Incident Report\nDatabase latency exceeded SLO threshold.\n"
	_ = vault.WriteAtomic(note1, content1)

	note2 := filepath.Join(tempDir, "02_Projects", "note2.md")
	content2 := "---\ntitle: Feature Plan\nservice: Flutter\ntags: [frontend]\n---\n# Plan\nBuilding the WYSIWYG editor for Spinel.\n"
	_ = vault.WriteAtomic(note2, content2)

	// Test FullText search
	matches, err := FullText(tempDir, "latency")
	if err != nil {
		t.Fatalf("FullText error: %v", err)
	}
	if len(matches) != 1 {
		t.Errorf("expected 1 match for 'latency', got %d", len(matches))
	} else if matches[0].LineNumber != 7 {
		t.Errorf("expected match on line 7, got %d", matches[0].LineNumber)
	}

	// Test Frontmatter search
	fmMatches, err := Frontmatter(tempDir, "service", "CloudSQL")
	if err != nil {
		t.Fatalf("Frontmatter error: %v", err)
	}
	if len(fmMatches) != 1 {
		t.Errorf("expected 1 match for frontmatter service:CloudSQL, got %d", len(fmMatches))
	}
}
