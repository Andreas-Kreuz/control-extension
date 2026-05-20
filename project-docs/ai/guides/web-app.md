# Web App Guide

## Stack

- React 19 + Vite + MUI (`apps/web-app`)
- Depends on server contract only via `apps/web-shared` — no direct Lua or DataBridge access

## Cypress Conventions

- No local helper functions (e.g. `chooseDirectory()`) if they break top-to-bottom readability
- Break chained `.` calls across lines instead of long single-line chains
- Generated screenshot filenames include the route slug from `generatedScreenshotPath`. When changing router paths or links used by screenshot specs, update any matching `/assets/generated/...` references in `pages/` so GitHub Pages asset generation can still find the produced screenshot.

## Commands

- Install dependencies: `yarn`
- Available root scripts: `yarn ce-help`
- Dev storybook: `cmd /c yarn dev:storybook` on Windows/PowerShell, otherwise `yarn dev:storybook`
- Format (non-Lua): `yarn format:apps`
- Format (all): `yarn format` — may fail on existing Liquid/HTML in `pages/docs/`; evaluate separately from your changes
- Developer workflows: `pages/docs/_anleitungen-entwickler/Aufbau_des_Projektes.md`

## Testing

- For web type or event changes, verify `@ce/web-shared` and affected consumers
- After changes run `yarn format:apps` if only non-Lua files are affected
- `yarn` is the package manager — check for stale `npm` references in docs/scripts when making changes
