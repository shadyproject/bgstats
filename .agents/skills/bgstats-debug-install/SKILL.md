---
name: bgstats-debug-install
description: Bundle the current BGStats checkout as a debug ZIP and install it into World of Warcraft Classic Anniversary. Use for local BGStats debug builds, installs, or reinstalls.
---

Run from the BGStats checkout to test, with Python 3.8 or later. Use the installed Python launcher (for example, `python3` on macOS or `py -3` on Windows).

1. Build and install with `python3 .agents/skills/bgstats-debug-install/scripts/install_debug.py`.
2. For a custom Battle.net install location, pass `--wow-root "/path/to/World of Warcraft"`. For a ZIP alone, pass `--bundle-only`.
3. Report the ZIP path and installed path from the script output. After installation, restart WoW or use `/reload` if BGStats was already loaded. Enable Lua error dialogs with `/console scriptErrors 1` when diagnosing runtime errors.

The ZIP and installed copy use the current working files. The debug TOC adds a visible title and version suffix. The addon keeps the BGStats folder and SavedVariables names, so installing replaces the existing BGStats copy and uses the character's existing data. The script edits only the addon directory under `_forever_` and writes the ZIP to `dist/`.
