---
name: control-extension-commands
description: Project-specific approval workflow for sandbox-sensitive commands in control-extension. Use before running Cypress commands or scripts, `yarn check`, `yarn test:app`, Jekyll documentation commands, release builds, or similarly broad/long-running project validation commands.
---

# Control Extension Commands

## Rule

For these commands and command paths, do not try a sandboxed run first and do not manually re-create the command from smaller subcommands:

- Cypress/app E2E root scripts: `yarn test:app`, `yarn test:app:ui`, `yarn test:web`, `yarn test`, `yarn build:docs:assets`, `yarn build:docs:assets:force`
- Cypress workspace scripts: `yarn workspace @ce/web-app run test:e2e`, `test:e2e:ui`, `test:e2e:headed`, `test:e2e:log`, `tools:cypress:open`, `tools:cypress:run`
- Direct Cypress wrappers: `node ./scripts/run-cypress.mjs ...`, `node ./scripts/run-update-doc-assets.mjs ...`, and direct `cypress` invocations
- Broad checks: `yarn check`, `yarn check:web`, or other check/test variants that include app, web, docs, or end-to-end validation
- Jekyll/docs scripts: `yarn dev:docs`, `yarn dev:docs:manual`, `yarn test:docs`, `yarn clean:docs`, `node ./scripts/run-jekyll.mjs ...`, and direct `bundle exec jekyll ...`
- Release/build packaging: `yarn build:release`, `yarn build:release:skiptests`, `yarn build:exe`, `node ./scripts/build-release.mjs`, and `node ./scripts/create-installer.mjs`

Request permission to run the exact intended command outside the sandbox using `sandbox_permissions: "require_escalated"` and a concise `justification`.

On Windows/PowerShell, prefer `yarn.cmd` for yarn commands unless the user explicitly asks for a different invocation.
