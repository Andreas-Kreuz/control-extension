# Work Rules

## Change Style

- Keep changes local and minimal — many modules are stateful; small targeted patches beat broad refactorings
- No unnecessary renames or formatting sweeps
- Prefer human-readable code over clever abstractions: use descriptive names, straightforward control flow, and small domain-focused helpers. Avoid generic helpers, deep indirection, and premature abstraction unless they clearly reduce real complexity.
- Do not reset existing local user changes
- Markdown files must use correct German umlauts — ASCII substitutions (`ae`, `oe`, `ue`) only for Lua identifiers
- Generated build artifacts (`*.tsbuildinfo`) must not be committed; check `.gitignore` for new cache files
- On Windows/PowerShell, always use `yarn.cmd` instead of `yarn`; PowerShell may route `yarn` through `yarn.ps1`, which can be blocked by execution policy
- Lua tool config locations: `luacheck` uses `lua/.luacheckrc`; `busted` uses `lua/.busted`
- For refactors of shared execution paths, do an impact search before finishing: find all usages of the changed API/behavior, inspect sibling modules using the same pattern, and update tests for every affected integration point. Avoid validating only the first visible failure.

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
