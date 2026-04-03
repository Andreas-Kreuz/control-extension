import {spawnSync} from 'node:child_process'

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

const args = ['--config-file', '.busted', '--verbose']

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
