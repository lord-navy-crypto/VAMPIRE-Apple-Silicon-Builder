# VAMPIRE Apple Silicon Builder

Unofficial native **Apple Silicon (arm64) macOS source builder** for the [VAMPIRE atomistic magnetic simulator](https://github.com/richard-evans/vampire).

This repository does **not** ship a VAMPIRE binary or a copy of the VAMPIRE source tree. It fetches a pinned upstream revision, switches the upstream LLVM compiler selector from `g++` to Apple `clang++`, builds the upstream `serial-llvm` target, verifies that the result is a native arm64 Mach-O executable, installs it into the current user's home directory, and runs the upstream sample as a smoke test.

## Status

Validated on Apple Silicon with:

- Architecture: `arm64`
- VAMPIRE: `7.0.0`
- Pinned upstream commit: `525bc27ee44c525aee229570f30f3d4c61d54f66`
- Build target: `serial-llvm`
- Compiler: Apple Clang
- Smoke test: passed using the upstream `input` + `Co.mat` sample

The validated sample created 10,648 atoms, constructed the neighbour list, ran the benchmark simulation, produced output, and exited gracefully.

## Quick start

### Finder

1. Download or clone this repository.
2. Double-click `START.command`.
3. If macOS asks for Command Line Tools, finish that installation and run `START.command` again.

### Terminal

```bash
chmod +x START.command scripts/*.sh
./START.command
```

The default installation prefix is:

```text
~/.local/vampire-apple-silicon
```

After installation, open a new Terminal and run:

```bash
vampire
```

## What the builder does

1. Confirms that the machine is Apple Silicon (`arm64`).
2. Confirms Apple Command Line Tools are available.
3. Downloads the exact pinned VAMPIRE commit.
4. Verifies the fetched commit.
5. Uses the upstream `serial-llvm` build path.
6. Changes only the upstream LLVM compiler selector from `g++` to `clang++`.
7. Compiles with the upstream flags.
8. Verifies the generated executable is arm64.
9. Installs the binary and sample files under the user-local prefix.
10. Records build provenance in `build-info/source.lock`.
11. Runs the upstream sample and requires an output file.

## Reproducibility

The upstream revision is pinned in `config/build.env` rather than tracking a moving branch. The installed build records:

- repository URL
- requested revision
- resolved commit
- architecture
- compiler
- build target
- builder version
- UTC build time

The provenance file is written to:

```text
~/.local/vampire-apple-silicon/build-info/source.lock
```

## Diagnostics

If a build fails, run:

```bash
./scripts/collect_diagnostics.sh
```

The script writes:

```text
~/Desktop/VAMPIRE_Apple_Silicon_Diagnostics.txt
```

Attach that file to a bug report.

## Uninstall

```bash
./scripts/uninstall.sh
```

## Scope

Current release scope:

- Apple Silicon only
- native arm64
- serial VAMPIRE build
- user-local installation
- pinned source revision
- automatic architecture verification
- automatic upstream sample smoke test
- no bundled VAMPIRE source or binary

MPI/parallel support is intentionally not part of this validated serial release yet.

## Repository self-check

Before publishing or tagging a release:

```bash
./scripts/repo_self_check.sh
```

To create a clean source-builder release archive:

```bash
./scripts/package_release.sh
```

## Upstream project and attribution

VAMPIRE is developed by the VAMPIRE project authors. This repository is an independent packaging/build helper and is not an official VAMPIRE distribution.

See `THIRD_PARTY_NOTICES.md` and the upstream license information fetched during installation.

## License

The build-helper code in this repository is provided under the MIT License; see `LICENSE`.

This MIT license applies only to the builder repository itself. VAMPIRE and bundled/upstream third-party components retain their own licenses.
