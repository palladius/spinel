package frontmatter

import (
	"bufio"
	"bytes"
	"fmt"
	"strings"

	"gopkg.in/yaml.v3"
)

// Document represents a Markdown file with parsed frontmatter and body.
type Document struct {
	Frontmatter map[string]interface{}
	Body        string
	Raw         string
}

// Parse extracts YAML frontmatter (between --- lines) and markdown body.
func Parse(content string) (*Document, error) {
	doc := &Document{
		Frontmatter: make(map[string]interface{}),
		Raw:         content,
	}

	trimmed := strings.TrimLeft(content, "\r\n\t ")
	if !strings.HasPrefix(trimmed, "---") {
		doc.Body = content
		return doc, nil
	}

	scanner := bufio.NewScanner(strings.NewReader(trimmed))
	var yamlLines []string
	var bodyLines []string
	inFrontmatter := false
	delimiterCount := 0

	for scanner.Scan() {
		line := scanner.Text()
		if strings.TrimSpace(line) == "---" {
			delimiterCount++
			if delimiterCount == 1 {
				inFrontmatter = true
				continue
			} else if delimiterCount == 2 {
				inFrontmatter = false
				continue
			}
		}

		if inFrontmatter {
			yamlLines = append(yamlLines, line)
		} else {
			bodyLines = append(bodyLines, line)
		}
	}

	if len(yamlLines) > 0 {
		yamlData := strings.Join(yamlLines, "\n")
		var parsed map[string]interface{}
		if err := yaml.Unmarshal([]byte(yamlData), &parsed); err != nil {
			return nil, fmt.Errorf("failed to unmarshal frontmatter YAML: %w", err)
		}
		if parsed != nil {
			doc.Frontmatter = parsed
		}
	}

	doc.Body = strings.Join(bodyLines, "\n")
	return doc, nil
}

// MatchQuery tests whether a document frontmatter satisfies a "key:value" query.
// Supports array contains (e.g. tags:work), substring matches, and exact value equality.
func (d *Document) MatchQuery(key, expectedVal string) bool {
	key = strings.TrimSpace(strings.ToLower(key))
	expectedVal = strings.TrimSpace(strings.ToLower(expectedVal))

	for k, v := range d.Frontmatter {
		if strings.ToLower(k) != key {
			continue
		}

		switch val := v.(type) {
		case string:
			if strings.EqualFold(val, expectedVal) || strings.Contains(strings.ToLower(val), expectedVal) {
				return true
			}
		case []interface{}:
			for _, item := range val {
				if itemStr, ok := item.(string); ok {
					if strings.EqualFold(itemStr, expectedVal) || strings.Contains(strings.ToLower(itemStr), expectedVal) {
						return true
					}
				} else if fmt.Sprintf("%v", item) == expectedVal {
					return true
				}
			}
		default:
			strVal := fmt.Sprintf("%v", val)
			if strings.EqualFold(strVal, expectedVal) || strings.Contains(strings.ToLower(strVal), expectedVal) {
				return true
			}
		}
	}
	return false
}

// FormatYAML returns the frontmatter serialized as YAML with --- delimiters.
func (d *Document) FormatYAML() (string, error) {
	if len(d.Frontmatter) == 0 {
		return "", nil
	}
	var buf bytes.Buffer
	buf.WriteString("---\n")
	encoder := yaml.NewEncoder(&buf)
	encoder.SetIndent(2)
	if err := encoder.Encode(d.Frontmatter); err != nil {
		return "", err
	}
	buf.WriteString("---\n")
	return buf.String(), nil
}
