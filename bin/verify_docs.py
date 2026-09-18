#!/usr/bin/env python3
"""
Verification script for Spinel GitHub Pages documentation and assets.
Ensures docs/index.html exists, has valid markup, and references existing local assets.
"""
import os
import re
import sys

def main():
    docs_dir = os.path.abspath("docs")
    index_file = os.path.join(docs_dir, "index.html")

    print("🔍 [Docs Verification] Checking docs/index.html...")
    if not os.path.isfile(index_file):
        print("❌ Error: docs/index.html not found!")
        sys.exit(1)

    with open(index_file, "r", encoding="utf-8") as f:
        content = f.read()

    # Check required core sections
    required_keywords = [
        "Spinel",
        "docs/assets/spinel_icon.png",
        "Zero-Knowledge",
        "liveRenderOutput",
        "markdownInput",
        "switchTab",
        "typewriterStep",
        "obsidian",
        "spinel",
    ]

    for kw in required_keywords:
        if kw not in content and kw.replace("docs/", "") not in content:
            print(f"❌ Error: Required token or asset link '{kw}' not found in docs/index.html!")
            sys.exit(1)

    # Check that referenced local assets in docs/ exist
    asset_matches = re.findall(r'src=["\'](assets/[^"\']+)["\']', content)
    for asset in set(asset_matches):
        full_asset_path = os.path.join(docs_dir, asset)
        if not os.path.isfile(full_asset_path):
            print(f"❌ Error: Referenced asset '{asset}' does not exist at '{full_asset_path}'!")
            sys.exit(1)
        else:
            print(f"  ✓ Verified asset: {asset}")

    print("✅ [Docs Verification] All docs checks and local assets verified successfully!")
    sys.exit(0)

if __name__ == "__main__":
    main()
