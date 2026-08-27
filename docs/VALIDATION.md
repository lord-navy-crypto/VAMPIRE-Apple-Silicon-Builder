# Validation record

The builder path represented by v0.1.3 was validated on an Apple Silicon Mac with the following results:

- architecture detected as `arm64`
- Apple Command Line Tools detected
- source commit resolved to `525bc27ee44c525aee229570f30f3d4c61d54f66`
- upstream `serial-llvm` target compiled with Apple `clang++`
- generated executable identified as `Mach-O 64-bit executable arm64`
- runtime dependencies resolved to macOS system libraries (`libc++` and `libSystem`)
- installation verification passed
- VAMPIRE 7.0.0 launched successfully
- upstream benchmark sample generated 10,648 atoms
- neighbour list generation completed
- benchmark simulation completed in approximately 8.3 seconds on the validation machine
- simulation ended gracefully
- smoke test produced an output file

This is a validation record for the tested configuration, not a guarantee for every Apple Silicon/macOS combination.
