# Contributing

Contributions are welcome for installer robustness, diagnostics, documentation, and additional validated macOS configurations.

## Before opening a pull request

1. Run `./scripts/repo_self_check.sh`.
2. Do not commit VAMPIRE source code or compiled VAMPIRE binaries to this repository.
3. Keep the tested upstream commit explicit and reproducible.
4. If changing build behavior, include the exact macOS version, CPU architecture, Apple Clang version, VAMPIRE commit, and relevant build log excerpt.
5. Preserve third-party license notices.

## Scope changes

Parallel/MPI support should be developed as an explicit new backend/path rather than silently changing the validated serial build.
