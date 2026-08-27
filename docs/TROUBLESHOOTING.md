# Troubleshooting

## Command Line Tools missing

Run the builder once. It will request installation through Apple's standard Command Line Tools installer. After installation completes, run `START.command` again.

## Builder says the machine is not arm64

This release intentionally supports only native Apple Silicon. Check:

```bash
uname -m
```

Expected result:

```text
arm64
```

## Source download appears slow

The builder prints a heartbeat every 10 seconds during long fetch/build operations, so a quiet network period should still show progress.

## Compilation fails

Run:

```bash
./scripts/collect_diagnostics.sh
```

Attach the generated diagnostics file to an issue.

## `vampire` is not found immediately after installation

Open a new Terminal so `~/.zprofile` is reloaded, or run:

```bash
source ~/.zprofile
```

## Smoke test fails

The install is treated as unsuccessful if the upstream sample does not exit successfully or fails to create its `output` file. Use the diagnostics collector and include the smoke-test section in the issue report.
