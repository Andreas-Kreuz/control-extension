import { execSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { findLuaCommand, REQUIRED_LUA_VERSION } from './lua-runtime.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// __dirname not required here, kept for style consistency with other scripts
void __dirname;

const REQUIRED_RUBY_VERSION = '3.3';
const REQUIRED_BUNDLER_VERSION = '4';

const tools = [
  {
    name: 'lua',
    purpose: `Lua ${REQUIRED_LUA_VERSION} runtime       — required for: build:release`,
    check: () => Boolean(findLuaCommand(REQUIRED_LUA_VERSION)),
    help: `Install Lua ${REQUIRED_LUA_VERSION} and ensure \`lua\`, \`lua53\`, or \`lua5.3\` is available in PATH.`,
  },
  {
    name: 'luacheck',
    purpose: 'Lua linter            — required for: lint:lua, check',
    help: 'Install `luacheck` and ensure the `luacheck` command is available in PATH.',
  },
  {
    name: 'busted',
    purpose: 'Lua test runner       — required for: test:lua, check',
    help: 'Install `busted` and ensure the `busted` command is available in PATH.',
  },
  {
    name: 'ruby',
    purpose: `Ruby ${REQUIRED_RUBY_VERSION} runtime      — required for: dev:docs, test:docs, check`,
    check: () => matchesVersion('ruby', '-e "print RUBY_VERSION"', REQUIRED_RUBY_VERSION),
    help: `Install Ruby ${REQUIRED_RUBY_VERSION}.x and ensure the \`ruby\` command in PATH points to that version.`,
  },
  {
    name: 'bundle',
    purpose: `Bundler ${REQUIRED_BUNDLER_VERSION}         — required for: dev:docs, test:docs, check`,
    check: () => matchesVersion('bundle', '--version', REQUIRED_BUNDLER_VERSION),
    help: `Install Bundler ${REQUIRED_BUNDLER_VERSION}.x for the active Ruby in PATH and regenerate \`Gemfile.lock\` with that Bundler version.`,
  },
  {
    name: 'jekyll',
    purpose: 'Jekyll docs stack      — required for: dev:docs, test:docs, check',
    check: () => isAvailable('bundle', `exec ruby -e "require 'jekyll'; require 'jemoji'"`),
    help: 'Run `bundle install` with Ruby 3.3 and Bundler 4 from PATH so the Jekyll gems, including `jemoji`, load successfully.',
  },
];

if (process.platform === 'win32') {
  tools.push({
    name: 'powershell',
    purpose: 'Windows PowerShell     — required for: build:release',
    args: '-NoProfile -Command "$PSVersionTable.PSVersion.ToString()"',
  });
}

function isAvailable(command, args = '--version') {
  try {
    execSync(`${command} ${args}`, { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

function readStdout(command, args) {
  try {
    return execSync(`${command} ${args}`, {
      stdio: ['ignore', 'pipe', 'ignore'],
      encoding: 'utf8',
    }).trim();
  } catch {
    return null;
  }
}

function matchesVersion(command, args, requiredPrefix) {
  const output = readStdout(command, args);
  if (!output) {
    return false;
  }
  return output.includes(requiredPrefix);
}

function isToolAvailable(tool) {
  if (tool.check) {
    return tool.check();
  }
  return isAvailable(tool.name, tool.args);
}

const nameWidth = Math.max(...tools.map((t) => t.name.length));

let allOk = true;
const missingTools = [];
console.log('\nChecking required external tools:\n');

for (const tool of tools) {
  const { name, purpose } = tool;
  const ok = isToolAvailable(tool);
  const status = ok ? 'OK     ' : 'MISSING';
  console.log(`  [${status}]  ${name.padEnd(nameWidth)}  ${purpose}`);
  if (!ok) {
    allOk = false;
    missingTools.push(tool);
  }
}

console.log('');

if (!allOk) {
  console.error('Install hints:');
  for (const tool of missingTools) {
    console.error(`  - ${tool.name}: ${tool.help}`);
  }
  console.error('');
  console.error('One or more required tools are missing. Install them and ensure they are in PATH.\n');
  process.exit(1);
}

console.log('All required tools are available.\n');
