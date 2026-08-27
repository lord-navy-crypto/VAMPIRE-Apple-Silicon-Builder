# Architecture

```text
GitHub repository
      |
      v
START.command
      |
      v
scripts/build_and_install.sh
      |
      +--> verify arm64 + Command Line Tools
      |
      +--> fetch pinned VAMPIRE commit
      |
      +--> verify commit SHA
      |
      +--> patch LLVM compiler selector: g++ -> clang++
      |
      +--> make serial-llvm
      |
      +--> verify Mach-O arm64
      |
      +--> install under ~/.local/vampire-apple-silicon
      |
      +--> write build-info/source.lock
      |
      +--> run upstream input + Co.mat smoke test
      |
      +--> require output file
      v
validated local VAMPIRE installation
```

The builder deliberately keeps VAMPIRE as an external upstream project. It does not vendor the upstream source tree or redistribute a binary.
