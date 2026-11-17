"""Build and install BGStats for local debugging."""

import argparse
import os
import re
import shutil
from pathlib import Path
from tempfile import TemporaryDirectory, mkdtemp
from zipfile import ZIP_DEFLATED, ZipFile


REPO = Path(__file__).resolve().parents[4]
CLIENT = "_forever_"
ARCHIVE = REPO / "dist" / "BGStats-debug.zip"


def find_client(wow_root):
    if wow_root is not None:
        candidates = [wow_root.expanduser()]
    else:
        candidates = [
            Path("/Applications/World of Warcraft"),
            Path.home() / "Applications" / "World of Warcraft",
        ]
        for variable in ("ProgramFiles(x86)", "ProgramFiles"):
            if os.environ.get(variable):
                candidates.append(Path(os.environ[variable]) / "World of Warcraft")

    clients = {root.resolve() / CLIENT for root in candidates if (root / CLIENT).is_dir()}
    if len(clients) != 1:
        raise ValueError(f"Expected one {CLIENT} client. Set --wow-root to its World of Warcraft folder.")
    return clients.pop()


def bundle():
    toc = (REPO / "BGStats.toc").read_text(encoding="utf-8")
    files = re.findall(r"^[A-Za-z0-9_./-]+\.lua$", toc, re.MULTILINE)
    debug_toc = re.sub(r"^(## Title: .+)$", r"\1 (Debug)", toc, flags=re.MULTILINE)
    debug_toc, versions = re.subn(
        r"^(## Version: .+)$", r"\1-debug", debug_toc, flags=re.MULTILINE
    )
    if not files or versions != 1:
        raise ValueError("BGStats.toc must list Lua files and exactly one version.")

    ARCHIVE.parent.mkdir(exist_ok=True)
    with TemporaryDirectory(dir=ARCHIVE.parent) as work:
        staged = Path(work) / ARCHIVE.name
        with ZipFile(staged, "w", compression=ZIP_DEFLATED) as archive:
            archive.writestr("BGStats/BGStats.toc", debug_toc)
            for file in ["README.md", "artwork/bgstats-icon.tga", *files]:
                archive.write(REPO / file, f"BGStats/{file}")
        staged.replace(ARCHIVE)


def install(client):
    interface = client / "Interface"
    addons = interface / "AddOns"
    addons.mkdir(parents=True, exist_ok=True)
    target = addons / "BGStats"
    # Stage beside AddOns to keep the rename on the same volume and outside WoW's scan path.
    staging_root = addons.resolve().parent
    lock = staging_root / ".bgstats-install-lock"
    lock.mkdir()
    try:
        work = Path(mkdtemp(dir=staging_root, prefix=".bgstats-"))
        backup = work / "previous"
        keep_backup = False
        try:
            with ZipFile(ARCHIVE) as archive:
                archive.extractall(work)
            if target.exists() or target.is_symlink():
                target.rename(backup)
                keep_backup = True
            try:
                (work / "BGStats").rename(target)
            except OSError:
                if keep_backup:
                    backup.rename(target)
                    keep_backup = False
                raise
            keep_backup = False
        finally:
            if not keep_backup:
                shutil.rmtree(work)
    finally:
        lock.rmdir()
    return target


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--wow-root", type=Path, help="World of Warcraft installation folder")
    mode.add_argument("--bundle-only", action="store_true", help="Build the ZIP without installing")
    args = parser.parse_args()

    try:
        client = None if args.bundle_only else find_client(args.wow_root)
        bundle()
        print(f"Bundled {ARCHIVE}", flush=True)
        if client is not None:
            print(f"Installed {install(client)}")
    except (OSError, ValueError) as error:
        parser.exit(1, f"{error}\n")


if __name__ == "__main__":
    main()
