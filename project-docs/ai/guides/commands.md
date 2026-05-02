# Commands Reference

Install: `yarn`

All root scripts: `yarn ce-help`

## Build & Run

```bash
yarn build                    # Build all (web-shared → web-app → web-server)
yarn build:docs:assets        # Generate missing docs screenshot/assets
yarn build:docs:assets:force  # Force-regenerate docs screenshot/assets
yarn dev:app                  # Dev mode: server + app in parallel
yarn dev:docs                 # Incremental docs server with LiveReload, creates missing assets
yarn dev:docs:manual          # Docs server with manual refresh, creates missing assets
yarn dev:storybook            # Storybook for the web app
yarn run:app                  # Build then run server
```

## Test

```bash
yarn test                   # All tests (Lua + server + app + docs)
yarn test:lua               # Busted/Lua tests only
yarn test:lua:coverage      # With coverage
yarn test:server            # Server tests only
yarn test:app               # Cypress E2E tests (requires build)
yarn check:lua              # lint:lua + test:lua
yarn check:web              # lint:web + test:web
```

Direct busted invocation: `busted --config-file lua/.busted --verbose --`

## Lint & Format

```bash
yarn lint                   # All (Lua + server + app + shared)
yarn lint:lua               # luacheck --config lua/.luacheckrc lua/LUA
yarn format                 # Format all (note: may error on pages/docs/ Liquid files)
yarn format:apps            # Format non-Lua files only
yarn format:lua             # Format Lua via sumneko.lua VSCode extension
```

## Other

- Dev storybook on Windows/PowerShell: `cmd /c yarn dev:storybook`
- Headless server: `yarn workspace @ce/web-server run run:headless`
- On Windows/PowerShell, run Yarn through `cmd /c`, e.g. `cmd /c yarn run check:lua`, instead of bare `yarn`.

.luacheckrc and .busted are located in lua/
