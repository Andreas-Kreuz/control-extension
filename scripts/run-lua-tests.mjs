import {spawnSync} from 'node:child_process'
import {findLuaCommand, listAvailableLuaCommands, REQUIRED_LUA_VERSION} from './lua-runtime.mjs'

function shouldUsePlainTerminalOutput() {
  const forcedOutput = process.env.CE_LUA_TEST_OUTPUT
  if (forcedOutput === 'plainTerminal') {
    return true
  }
  if (forcedOutput === 'utf8') {
    return false
  }

  if (process.platform !== 'win32') {
    return false
  }

  return !process.env.PSModulePath
}

const args = ['--config-file', 'lua/.busted', '--verbose']
const luaCommand = findLuaCommand(REQUIRED_LUA_VERSION)

if (!luaCommand) {
  const availableLuaVersions = listAvailableLuaCommands().map((probe) => `${probe.command} (${probe.version})`)
  const availableLuaText = availableLuaVersions.length > 0
    ? ` Found: ${availableLuaVersions.join(', ')}.`
    : ''

  console.error(
    `Lua ${REQUIRED_LUA_VERSION} is required for yarn test:lua.${availableLuaText} ` +
    'Install Lua 5.3 so it is available in PATH.'
  )
  process.exit(1)
}

if (shouldUsePlainTerminalOutput()) {
  args.push('--output=plainTerminal')
}

if (process.argv.includes('--coverage')) {
  args.push('--coverage')
}

args.push('--')

const result = spawnSync('busted', args, {
  shell: process.platform === 'win32',
  stdio: 'inherit',
  windowsHide: true,
})

if (typeof result.status === 'number') {
  process.exit(result.status)
}

process.exit(1)
