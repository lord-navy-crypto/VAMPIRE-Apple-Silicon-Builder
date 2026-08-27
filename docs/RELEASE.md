# Release procedure

1. Run `./scripts/repo_self_check.sh`.
2. Validate the builder on a clean Apple Silicon Mac.
3. Confirm `VERIFY PASS`, `SMOKE PASS`, and `SUCCESS`.
4. Review `config/build.env` and confirm the pinned VAMPIRE commit.
5. Run `./scripts/package_release.sh`.
6. Upload the generated ZIP and SHA-256 file as GitHub Release assets.
7. Tag the repository with the builder version, for example `v0.1.3`.

Do not include locally built VAMPIRE binaries in the repository unless you have separately reviewed all redistribution obligations and intentionally choose to distribute them.
