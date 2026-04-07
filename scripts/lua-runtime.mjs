import {spawnSync} from 'node:child_process'
import {existsSync} from 'node:fs'
import {join} from 'node:path'

export const REQUIRED_LUA_VERSION = '5.3'

function getLuaCandidates() {
  const baseCandidates = process.platform === 'win32'
    ? ['lua53', 'lua5.3', 'lua']
    : ['lua5.3', 'lua53', 'lua']

  if (process.platform !== 'win32') {
    return baseCandidates
  }

  const discoveredPaths = []
  const pathEntries = (process.env.PATH ?? '')
    .split(';')
    .map((entry) => entry.trim())
    .filter(Boolean)

  for (const pathEntry of pathEntries) {
    for (const candidate of baseCandidates) {
      const directPath = join(pathEntry, candidate)
      const exePath = join(pathEntry, `${candidate}.exe`)
      if (existsSync(directPath)) {
        discoveredPaths.push(directPath)
      }
      if (existsSync(exePath)) {
        discoveredPaths.push(exePath)
      }
    }
  }

  return [...new Set([...discoveredPaths, ...baseCandidates])]
}

function parseLuaVersion(output) {
  const match = output.match(/Lua\s+(\d+\.\d+)/)
  return match ? match[1] : null
}

function probeLuaCommand(command) {
  const result = spawnSync(command, ['-v'], {
    encoding: 'utf8',
    shell: false,
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
