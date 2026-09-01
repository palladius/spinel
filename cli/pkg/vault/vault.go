package vault

import (
	"fmt"
	"io"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/palladius/spinel/cli/pkg/frontmatter"
)

// Note represents an individual markdown file inside a vault.
type Note struct {
	Path         string
	RelativePath string
	Doc          *frontmatter.Document
}

// Init creates a new Spinel vault at rootPath.
func Init(rootPath, vaultName string) error {
	if rootPath == "" {
		rootPath = "."
	}
	absPath, err := filepath.Abs(rootPath)
	if err != nil {
		return err
	}

	dirs := []string{
		absPath,
		filepath.Join(absPath, ".spinel"),
		filepath.Join(absPath, "01_Daily_Notes"),
		filepath.Join(absPath, "02_Projects"),
		filepath.Join(absPath, "03_Resources"),
	}

	for _, d := range dirs {
		if err := os.MkdirAll(d, 0755); err != nil {
			return fmt.Errorf("failed to create directory %s: %w", d, err)
		}
	}

	// Create config.yaml
	configPath := filepath.Join(absPath, ".spinel", "config.yaml")
	if _, err := os.Stat(configPath); os.IsNotExist(err) {
		cfg := fmt.Sprintf("name: %q\nversion: \"0.1.0\"\ncreated_with: \"spinel-cli\"\n", vaultName)
		if err := os.WriteFile(configPath, []byte(cfg), 0644); err != nil {
			return err
		}
	}

	// Create .gitignore
	gitignorePath := filepath.Join(absPath, ".gitignore")
	if _, err := os.Stat(gitignorePath); os.IsNotExist(err) {
		gi := "# Spinel local ignore\n.DS_Store\n.spinel/cache/\n*.tmp\n"
		if err := os.WriteFile(gitignorePath, []byte(gi), 0644); err != nil {
			return err
		}
	}

	// Create README.md
	readmePath := filepath.Join(absPath, "README.md")
	if _, err := os.Stat(readmePath); os.IsNotExist(err) {
		readme := fmt.Sprintf("# 💎 %s\n\nWelcome to your **Spinel** markdown knowledge vault.\n\n- `01_Daily_Notes/`: Daily journals and logs\n- `02_Projects/`: Active project documentation\n- `03_Resources/`: Reference guides and cheatsheets\n", vaultName)
		if err := os.WriteFile(readmePath, []byte(readme), 0644); err != nil {
			return err
		}
	}

	// Initialize git if .git does not exist
	gitDir := filepath.Join(absPath, ".git")
	if _, err := os.Stat(gitDir); os.IsNotExist(err) {
		cmd := exec.Command("git", "init")
		cmd.Dir = absPath
		_ = cmd.Run()
	}

	return nil
}

// Walk finds and returns all .md notes in the vault directory.
func Walk(rootPath string) ([]*Note, error) {
	absPath, err := filepath.Abs(rootPath)
	if err != nil {
		return nil, err
	}

	var notes []*Note

	err = filepath.WalkDir(absPath, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() {
			name := d.Name()
			if strings.HasPrefix(name, ".") && name != "." {
				return filepath.SkipDir
			}
			if name == "node_modules" || name == "vendor" || name == "dist" {
				return filepath.SkipDir
			}
			return nil
		}

		if strings.HasSuffix(strings.ToLower(d.Name()), ".md") {
			content, err := os.ReadFile(path)
			if err != nil {
				return nil
			}
			doc, err := frontmatter.Parse(string(content))
			if err != nil {
				return nil
			}
			relPath, err := filepath.Rel(absPath, path)
			if err != nil {
				relPath = path
			}
			notes = append(notes, &Note{
				Path:         path,
				RelativePath: relPath,
				Doc:          doc,
			})
		}
		return nil
	})

	return notes, err
}

// WriteAtomic writes content to targetPath atomically via tempfile rename.
func WriteAtomic(targetPath, content string) error {
	dir := filepath.Dir(targetPath)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return err
	}

	tmpFile, err := os.CreateTemp(dir, "spinel-tmp-*.md")
	if err != nil {
		return err
	}
	tmpName := tmpFile.Name()
	defer os.Remove(tmpName)

	if _, err := io.WriteString(tmpFile, content); err != nil {
		tmpFile.Close()
		return err
	}
	if err := tmpFile.Close(); err != nil {
		return err
	}

	return os.Rename(tmpName, targetPath)
}
