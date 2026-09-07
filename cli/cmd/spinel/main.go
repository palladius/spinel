package main

import (
	"fmt"
	"os"
	"strings"

	"github.com/fatih/color"
	"github.com/palladius/spinel/cli/pkg/export"
	"github.com/palladius/spinel/cli/pkg/search"
	syncpkg "github.com/palladius/spinel/cli/pkg/sync"
	"github.com/palladius/spinel/cli/pkg/vault"
	"github.com/spf13/cobra"
)

var (
	version   = "0.2.2"
	vaultPath string
)

func main() {
	rootCmd := &cobra.Command{
		Use:   "spinel",
		Short: "💎 Spinel: Ultra-fast, local-first Markdown knowledge vault CLI",
		Long:  `Spinel is an open, private, git-friendly Markdown knowledge base CLI.`,
	}

	rootCmd.PersistentFlags().StringVarP(&vaultPath, "vault", "V", ".", "Path to Spinel vault root directory")

	// init command
	initCmd := &cobra.Command{
		Use:   "init [path]",
		Short: "Initialize a new Spinel markdown vault",
		Args:  cobra.MaximumNArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			target := "."
			if len(args) > 0 {
				target = args[0]
			}
			vaultName := "My Vault"
			if name, _ := cmd.Flags().GetString("name"); name != "" {
				vaultName = name
			}
			err := vault.Init(target, vaultName)
			if err != nil {
				return err
			}
			color.Green("💎 Initialized Spinel vault %q at %s", vaultName, target)
			return nil
		},
	}
	initCmd.Flags().StringP("name", "n", "My Vault", "Name of the vault")

	// search command
	searchCmd := &cobra.Command{
		Use:   "search <query>",
		Short: "Perform full-text search across all markdown notes in vault",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			query := args[0]
			matches, err := search.FullText(vaultPath, query)
			if err != nil {
				return err
			}

			if len(matches) == 0 {
				color.Yellow("🔍 No matches found for %q in %s", query, vaultPath)
				return nil
			}

			color.Cyan("🔍 Found %d match(es) for %q:", len(matches), query)
			cyan := color.New(color.FgCyan, color.Bold).SprintFunc()
			yellow := color.New(color.FgYellow).SprintFunc()
			highlight := color.New(color.FgHiWhite, color.BgRed).SprintFunc()

			for _, m := range matches {
				highlighted := strings.ReplaceAll(m.LineContent, query, highlight(query))
				fmt.Printf("  📄 %s:%s %s\n", cyan(m.RelativePath), yellow(fmt.Sprintf("%d", m.LineNumber)), highlighted)
			}
			return nil
		},
	}

	// search-frontmatter command
	searchFMCmd := &cobra.Command{
		Use:     "search-frontmatter <key:value>",
		Aliases: []string{"sfm"},
		Short:   "Search notes matching YAML frontmatter key/value (e.g. tags:sre, event:work)",
		Args:    cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			parts := strings.SplitN(args[0], ":", 2)
			if len(parts) != 2 {
				return fmt.Errorf("invalid query format: expected key:value (e.g. tags:sre)")
			}
			key, val := parts[0], parts[1]
			notes, err := search.Frontmatter(vaultPath, key, val)
			if err != nil {
				return err
			}

			if len(notes) == 0 {
				color.Yellow("🏷️  No notes found matching frontmatter %s:%s", key, val)
				return nil
			}

			color.Magenta("🏷️  Found %d note(s) matching [%s: %s]:", len(notes), key, val)
			for _, n := range notes {
				title := n.RelativePath
				if t, ok := n.Doc.Frontmatter["title"].(string); ok {
					title = fmt.Sprintf("%s (%s)", t, n.RelativePath)
				}
				fmt.Printf("  💎 %s\n", color.HiWhiteString(title))
			}
			return nil
		},
	}

	// sync command
	syncCmd := &cobra.Command{
		Use:   "sync",
		Short: "Synchronize local vault with Cloud SQL / Rails backend using zero-knowledge encryption",
		RunE: func(cmd *cobra.Command, args []string) error {
			remoteURL, _ := cmd.Flags().GetString("remote")
			token, _ := cmd.Flags().GetString("token")
			passphrase, _ := cmd.Flags().GetString("passphrase")

			if remoteURL == "" {
				return fmt.Errorf("--remote <url> is required (e.g. https://spinel-api.run.app)")
			}
			if token == "" {
				token = os.Getenv("SPINEL_API_KEY")
			}
			if token == "" {
				return fmt.Errorf("--token <api_key> or SPINEL_API_KEY environment variable is required")
			}
			if passphrase == "" {
				passphrase = os.Getenv("SPINEL_PASSPHRASE")
			}
			if passphrase == "" {
				return fmt.Errorf("--passphrase <passphrase> or SPINEL_PASSPHRASE environment variable is required")
			}

			color.Cyan("🔄 Synchronizing %s with %s...", vaultPath, remoteURL)
			resp, err := syncpkg.PerformSync(vaultPath, remoteURL, token, passphrase)
			if err != nil {
				return err
			}

			color.Green("✅ Sync complete! %d local changes applied. %d remote updates received.", resp.AppliedCount, len(resp.ServerDeltas))
			return nil
		},
	}
	syncCmd.Flags().StringP("remote", "r", "", "Remote Spinel Rails API URL")
	syncCmd.Flags().StringP("token", "t", "", "Vault API authorization token")
	syncCmd.Flags().StringP("passphrase", "p", "", "Zero-knowledge encryption passphrase")

	// export command
	exportCmd := &cobra.Command{
		Use:   "export",
		Short: "Export vault into an archive",
		RunE: func(cmd *cobra.Command, args []string) error {
			tarOut, _ := cmd.Flags().GetString("tar")
			if tarOut == "" {
				return fmt.Errorf("--tar <file.tar.gz> output path is required")
			}
			err := export.VaultToTarGz(vaultPath, tarOut)
			if err != nil {
				return err
			}
			color.Green("📦 Successfully exported vault to %s", tarOut)
			return nil
		},
	}
	exportCmd.Flags().String("tar", "", "Output path for .tar.gz archive")

	// version command
	versionCmd := &cobra.Command{
		Use:   "version",
		Short: "Print Spinel CLI version",
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Printf("Spinel CLI version %s (Go 1.22+ / darwin-arm64)\n", version)
		},
	}

	// list command (helper)
	listCmd := &cobra.Command{
		Use:   "list",
		Short: "List all notes in the vault",
		RunE: func(cmd *cobra.Command, args []string) error {
			notes, err := vault.Walk(vaultPath)
			if err != nil {
				return err
			}
			color.Cyan("📂 Vault Notes in %s (%d total):", vaultPath, len(notes))
			for _, n := range notes {
				fmt.Printf("  • %s\n", n.RelativePath)
			}
			return nil
		},
	}

	rootCmd.AddCommand(initCmd, searchCmd, searchFMCmd, syncCmd, exportCmd, versionCmd, listCmd)

	if err := rootCmd.Execute(); err != nil {
		os.Exit(1)
	}
}
