import {spawnSync} from 'node:child_process'

export const REQUIRED_LUA_VERSION = '5.3'

function getLuaCandidates() {
  const candidates = process.platform === 'win32'
    ? ['lua53', 'lua5.3', 'lua']
    : ['lua5.3', 'lua53', 'lua']

  return candidates
}

function parseLuaVersion(output) {
  const match = output.match(/Lua\s+(\d+\.\d+)/)
  return match ? match[1] : null
}

function probeLuaCommand(command) {
  const result = spawnSync(command, ['-v'], {
    encoding: 'utf8',
    shell: process.platform === 'win32',
    windowsHide: true,
  })

  if (result.error || result.status !== 0) {
    return null
  }

  const output = `${result.stdout ?? ''}${result.stderr ?? ''}`.trim()
  const version = parseLuaVersion(output)
  if (!version) {
    return null
  }

  return {command, version, output}
}

export function listAvailableLuaCommands() {
  return getLuaCandidates()
    .map(probeLuaCommand)
    .filter(Boolean)
}

export function findLuaCommand(requiredVersion = REQUIRED_LUA_VERSION) {
  return listAvailableLuaCommands().find((probe) => probe.version === requiredVersion) ?? null
}
