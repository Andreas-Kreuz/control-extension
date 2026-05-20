---
name: control-extension-commands
description: Project-specific approval workflow for sandbox-sensitive commands in control-extension. Use before running any yarn command that may include web app tests or checks, Cypress commands or scripts, Jekyll documentation commands, release builds, or similarly broad/long-running project validation commands.
---

# Control Extension Commands

## Rule

Use this skill before running yarn commands that may include web app tests or checks, even if the user names the command in bare-yarn form such as `yarn check`, `yarn check:app`, `yarn check:web`, `yarn test:app`, or `yarn test:web`.

It is critical that web app tests run outside the sandbox. For matching commands, request permission to run the exact intended command outside the sandbox using `sandbox_permissions: "require_escalated"` and a concise `justification`.

For these commands and command paths, do not try a sandboxed run first and do not manually re-create the command from smaller subcommands:

- Cypress/app E2E root scripts: `cmd /c yarn.cmd test:app`, `cmd /c yarn.cmd test:app -- --spec cypress/e2e/home/home.cy.ts`, `cmd /c yarn.cmd test:app:ui`, `cmd /c yarn.cmd test:web`, `cmd /c yarn.cmd test`, `cmd /c yarn.cmd build:docs:assets`, `cmd /c yarn.cmd build:docs:assets:force`
- Cypress workspace scripts: `cmd /c yarn.cmd workspace @ce/web-app run test:e2e`, `cmd /c yarn.cmd workspace @ce/web-app run test:e2e:ui`, `cmd /c yarn.cmd workspace @ce/web-app run test:e2e:headed`, `cmd /c yarn.cmd workspace @ce/web-app run test:e2e:log`, `cmd /c yarn.cmd workspace @ce/web-app run tools:cypress:open`, `cmd /c yarn.cmd workspace @ce/web-app run tools:cypress:run`
- Direct Cypress wrappers: `node ./scripts/run-app-e2e.mjs ...`, `node ./scripts/run-cypress.mjs ...`, `node ./scripts/run-update-doc-assets.mjs ...`, and direct `cypress` invocations
- Broad checks: `cmd /c yarn.cmd check`, `cmd /c yarn.cmd check:app`, `cmd /c yarn.cmd check:web`, or other check/test variants that include app, web, docs, or end-to-end validation
- Jekyll/docs scripts: `cmd /c yarn.cmd dev:docs`, `cmd /c yarn.cmd dev:docs:manual`, `cmd /c yarn.cmd test:docs`, `cmd /c yarn.cmd clean:docs`, `node ./scripts/run-jekyll.mjs ...`, and direct `bundle exec jekyll ...`
- Release/build packaging: `cmd /c yarn.cmd build:release`, `cmd /c yarn.cmd build:release:skiptests`, `cmd /c yarn.cmd build:exe`, `node ./scripts/build-release.mjs`, and `node ./scripts/create-installer.mjs`

All yarn commands must be run through `cmd /c yarn.cmd`, for example `cmd /c yarn.cmd test:app`. Do not use bare `yarn`, `yarn.cmd` without `cmd /c`, or `cmd /c yarn`; those invocations can fail in this project.

`test:app` accepts Cypress CLI arguments after `--`. Prefer a small subset during iterative verification, for example `cmd /c yarn.cmd test:app -- --spec cypress/e2e/home/home.cy.ts`.
