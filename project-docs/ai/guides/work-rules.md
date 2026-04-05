# Work Rules

## Change Style

- Keep changes local and minimal — many modules are stateful; small targeted patches beat broad refactorings
- No unnecessary renames or formatting sweeps
- Do not reset existing local user changes
- Markdown files must use correct German umlauts — ASCII substitutions (`ae`, `oe`, `ue`) only for Lua identifiers
- Generated build artifacts (`*.tsbuildinfo`) must not be committed; check `.gitignore` for new cache files
- On Windows/PowerShell, `yarn.cmd` is more robust than `yarn` due to execution policy

## Review Focus

- State consistency
- Persistence errors
- EEP / callback integration
- Behavioral regressions
- Missing tests

## Package Scripts

- When changing `package.json` scripts, check if help needs updating:
  - Root scripts must be documented in `yarn ce-help` / `scripts/ce-help.mjs`
  - Important workspace scripts must be documented in the relevant package README or context docs
- Mark markdown files with planned but unimplemented target state clearly as `TODO`, `Roadmap`, or `Zielbild`
