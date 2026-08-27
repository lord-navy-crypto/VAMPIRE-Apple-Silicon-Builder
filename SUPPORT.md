# Support

For build failures, run:

```bash
./scripts/collect_diagnostics.sh
```

Then attach the generated `VAMPIRE_Apple_Silicon_Diagnostics.txt` file to a GitHub issue.

Useful information includes:

- Mac model / Apple Silicon generation
- macOS version
- `uname -m`
- Apple Clang version
- exact builder version
- whether Command Line Tools are installed
- the final 100–300 lines of the builder log
