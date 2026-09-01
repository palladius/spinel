package frontmatter

import (
	"testing"
)

func TestParseValidFrontmatter(t *testing.T) {
	raw := `---
title: "Project Alpha"
author: "Riccardo"
tags:
  - sre
  - cloud
priority: 1
---

# Heading 1
This is the note body.
`
	doc, err := Parse(raw)
	if err != nil {
		t.Fatalf("unexpected error parsing frontmatter: %v", err)
	}

	if doc.Frontmatter["title"] != "Project Alpha" {
		t.Errorf("expected title 'Project Alpha', got '%v'", doc.Frontmatter["title"])
	}
	if doc.Frontmatter["author"] != "Riccardo" {
		t.Errorf("expected author 'Riccardo', got '%v'", doc.Frontmatter["author"])
	}

	// Test MatchQuery
	if !doc.MatchQuery("author", "riccardo") {
		t.Errorf("expected MatchQuery author:riccardo to be true")
	}
	if !doc.MatchQuery("tags", "sre") {
		t.Errorf("expected MatchQuery tags:sre to be true")
	}
	if !doc.MatchQuery("tags", "cloud") {
		t.Errorf("expected MatchQuery tags:cloud to be true")
	}
	if doc.MatchQuery("tags", "ruby") {
		t.Errorf("expected MatchQuery tags:ruby to be false")
	}
}

func TestParseNoFrontmatter(t *testing.T) {
	raw := "# Pure Markdown\nJust some notes without frontmatter."
	doc, err := Parse(raw)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(doc.Frontmatter) != 0 {
		t.Errorf("expected empty frontmatter, got %v", doc.Frontmatter)
	}
	if doc.Body != raw {
		t.Errorf("expected body '%s', got '%s'", raw, doc.Body)
	}
}
