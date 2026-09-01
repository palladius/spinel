package export

import (
	"archive/tar"
	"compress/gzip"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
)

// VaultToTarGz archives the entire vault at rootPath into an output .tar.gz file.
func VaultToTarGz(rootPath, outputPath string) error {
	absRoot, err := filepath.Abs(rootPath)
	if err != nil {
		return err
	}

	outFile, err := os.Create(outputPath)
	if err != nil {
		return fmt.Errorf("failed to create export file: %w", err)
	}
	defer outFile.Close()

	gw := gzip.NewWriter(outFile)
	defer gw.Close()

	tw := tar.NewWriter(gw)
	defer tw.Close()

	return filepath.WalkDir(absRoot, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		relPath, err := filepath.Rel(absRoot, path)
		if err != nil {
			return err
		}
		if relPath == "." {
			return nil
		}

		// Skip hidden dotfiles except essential vault configs
		if d.IsDir() {
			if strings.HasPrefix(d.Name(), ".") && d.Name() != ".spinel" {
				return filepath.SkipDir
			}
			if d.Name() == "node_modules" || d.Name() == "vendor" {
				return filepath.SkipDir
			}
		}

		info, err := d.Info()
		if err != nil {
			return err
		}

		header, err := tar.FileInfoHeader(info, "")
		if err != nil {
			return err
		}
		header.Name = filepath.ToSlash(relPath)

		if err := tw.WriteHeader(header); err != nil {
			return err
		}

		if d.IsDir() {
			return nil
		}

		file, err := os.Open(path)
		if err != nil {
			return err
		}
		defer file.Close()

		_, err = io.Copy(tw, file)
		return err
	})
}
