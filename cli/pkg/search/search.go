package search

import (
	"bufio"
	"os"
	"strings"

	"github.com/palladius/spinel/cli/pkg/vault"
)

// Match represents a line match in a markdown note.
type Match struct {
	NotePath     string
	RelativePath string
	LineNumber   int
	LineContent  string
}

// FullText searches for substring query in all notes in the vault.
func FullText(rootPath, query string) ([]Match, error) {
	notes, err := vault.Walk(rootPath)
	if err != nil {
		return nil, err
	}

	queryLower := strings.ToLower(query)
	var matches []Match

	for _, note := range notes {
		file, err := os.Open(note.Path)
		if err != nil {
			continue
		}
		scanner := bufio.NewScanner(file)
		lineNum := 0
		for scanner.Scan() {
			lineNum++
			line := scanner.Text()
			if strings.Contains(strings.ToLower(line), queryLower) {
				matches = append(matches, Match{
					NotePath:     note.Path,
					RelativePath: note.RelativePath,
					LineNumber:   lineNum,
					LineContent:  line,
				})
			}
		}
		file.Close()
	}

	return matches, nil
}

// Frontmatter searches for notes whose frontmatter satisfies key:value.
func Frontmatter(rootPath, key, val string) ([]*vault.Note, error) {
	notes, err := vault.Walk(rootPath)
	if err != nil {
		return nil, err
	}

	var results []*vault.Note
	for _, note := range notes {
		if note.Doc != nil && note.Doc.MatchQuery(key, val) {
			results = append(results, note)
		}
	}
	return results, nil
}
