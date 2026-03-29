import { spawn } from 'node:child_process';
import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const EXCLUDED_SEGMENTS = new Set(['anlagen', 'demo-anlagen', 'third-party']);
const SKIPPED_ROOT_SEGMENTS = new Set(['.git', '.yarn', 'node_modules']);

function printHelp() {
  console.log(`
Formats Lua files with the locally installed VSCode formatter "sumneko.lua".

Usage:
  yarn format-lua
  yarn format-lua -- <file-or-directory> [...]

Behavior:
  - Scans all .lua files below the current workspace when no paths are given
  - Excludes every path whose directory segments contain "anlagen", "demo-anlagen", or "third-party"
  - Reads and writes .lua files as latin1 to avoid damaging repo encoding
`);
}

function isExcludedPath(filePath, workspaceRoot) {
  const relativePath = path.relative(workspaceRoot, filePath);
  const segments = relativePath.split(/[\\/]+/).map((segment) => segment.toLowerCase());
  return segments.some((segment) => EXCLUDED_SEGMENTS.has(segment));
}

async function pathExists(targetPath) {
  try {
    await fs.access(targetPath);
    return true;
  } catch {
    return false;
  }
}

async function collectLuaFilesFromDirectory(directoryPath, workspaceRoot, files) {
  const entries = await fs.readdir(directoryPath, { withFileTypes: true });
  for (const entry of entries) {
    const entryPath = path.join(directoryPath, entry.name);
    const entryNameLower = entry.name.toLowerCase();

    if (entry.isDirectory()) {
      if (SKIPPED_ROOT_SEGMENTS.has(entryNameLower) || EXCLUDED_SEGMENTS.has(entryNameLower)) {
        continue;
      }
      await collectLuaFilesFromDirectory(entryPath, workspaceRoot, files);
      continue;
    }

    if (!entry.isFile()) {
      continue;
    }

    if (!entryNameLower.endsWith('.lua')) {
      continue;
    }

    if (!isExcludedPath(entryPath, workspaceRoot)) {
      files.add(path.resolve(entryPath));
    }
  }
}

async function resolveTargetFiles(rawArgs, workspaceRoot) {
  const files = new Set();

  if (rawArgs.length === 0) {
    await collectLuaFilesFromDirectory(workspaceRoot, workspaceRoot, files);
    return [...files].sort();
  }

  for (const rawArg of rawArgs) {
    const absolutePath = path.resolve(workspaceRoot, rawArg);
    const stats = await fs.stat(absolutePath).catch(() => null);
    if (!stats) {
      throw new Error(`Pfad nicht gefunden: ${rawArg}`);
    }

    if (stats.isDirectory()) {
      if (!isExcludedPath(absolutePath, workspaceRoot)) {
        await collectLuaFilesFromDirectory(absolutePath, workspaceRoot, files);
      }
      continue;
    }

    if (stats.isFile() && absolutePath.toLowerCase().endsWith('.lua') && !isExcludedPath(absolutePath, workspaceRoot)) {
      files.add(absolutePath);
    }
  }

  return [...files].sort();
}

function parseVersionFromExtensionName(name) {
  const match = /^sumneko\.lua-(\d+)\.(\d+)\.(\d+)/i.exec(name);
  if (!match) {
    return null;
  }

  return match.slice(1).map((part) => Number.parseInt(part, 10));
}

function compareVersions(a, b) {
  const maxLength = Math.max(a.length, b.length);
  for (let index = 0; index < maxLength; index += 1) {
    const left = a[index] ?? 0;
    const right = b[index] ?? 0;
    if (left !== right) {
      return left - right;
    }
  }
  return 0;
}

async function findLuaLanguageServer() {
  const extensionsRoot = process.env.VSCODE_EXTENSIONS ?? path.join(os.homedir(), '.vscode', 'extensions');

  const extensionEntries = await fs.readdir(extensionsRoot, { withFileTypes: true });
  const candidates = extensionEntries
    .filter((entry) => entry.isDirectory())
    .map((entry) => ({
      name: entry.name,
      version: parseVersionFromExtensionName(entry.name),
      extensionPath: path.join(extensionsRoot, entry.name),
    }))
    .filter((entry) => entry.version);

  if (candidates.length === 0) {
    throw new Error(`Keine installierte VSCode-Erweiterung "sumneko.lua" gefunden unter ${extensionsRoot}.`);
  }

  candidates.sort((left, right) => compareVersions(right.version, left.version));

  const executableNames =
    process.platform === 'win32'
      ? ['lua-language-server.exe', 'lua-language-server']
      : ['lua-language-server', 'lua-language-server.exe'];

  for (const candidate of candidates) {
    for (const executableName of executableNames) {
      const serverPath = path.join(candidate.extensionPath, 'server', 'bin', executableName);
      if (await pathExists(serverPath)) {
        return {
          extensionName: candidate.name,
          serverPath,
        };
      }
    }
  }

  throw new Error('In keiner gefundenen sumneko.lua-Erweiterung wurde eine passende LuaLS-Binary gefunden.');
}

async function loadWorkspaceSettings(workspaceRoot) {
  const settingsPath = path.join(workspaceRoot, '.vscode', 'settings.json');
  if (!(await pathExists(settingsPath))) {
    return {};
  }

  const raw = await fs.readFile(settingsPath, 'utf8');
  return JSON.parse(raw);
}

function setNestedValue(target, dottedPath, value) {
  const parts = dottedPath.split('.');
  let cursor = target;

  for (let index = 0; index < parts.length - 1; index += 1) {
    const part = parts[index];
    if (typeof cursor[part] !== 'object' || cursor[part] === null || Array.isArray(cursor[part])) {
      cursor[part] = {};
    }
    cursor = cursor[part];
  }

  cursor[parts.at(-1)] = value;
}

function buildLuaSection(settings) {
  const luaSection = {};

  for (const [key, value] of Object.entries(settings)) {
    if (!key.startsWith('Lua.')) {
      continue;
    }
    setNestedValue(luaSection, key.slice('Lua.'.length), value);
  }

  luaSection.format ??= {};
  if (luaSection.format.enable === undefined) {
    luaSection.format.enable = true;
  }

  luaSection.runtime ??= {};
  if (luaSection.runtime.fileEncoding === undefined) {
    luaSection.runtime.fileEncoding = 'ansi';
  }

  return luaSection;
}

function buildWorkspaceConfiguration(settings) {
  return {
    Lua: buildLuaSection(settings),
    'files.associations': settings['files.associations'] ?? {},
    'files.exclude': settings['files.exclude'] ?? {},
    'editor.semanticHighlighting.enabled': settings['editor.semanticHighlighting.enabled'] ?? true,
    'editor.acceptSuggestionOnEnter': settings['editor.acceptSuggestionOnEnter'] ?? 'on',
  };
}

function encodeMessage(message) {
  const body = Buffer.from(JSON.stringify(message), 'utf8');
  const header = Buffer.from(`Content-Length: ${body.length}\r\n\r\n`, 'ascii');
  return Buffer.concat([header, body]);
}

class LspClient {
  constructor({ serverPath, workspaceRoot, configuration }) {
    this.serverPath = serverPath;
    this.workspaceRoot = workspaceRoot;
    this.workspaceUri = pathToFileURL(workspaceRoot).href;
    this.configuration = configuration;
    this.process = null;
    this.stdoutBuffer = Buffer.alloc(0);
    this.nextRequestId = 1;
    this.pendingRequests = new Map();
    this.stderrOutput = [];
  }

  async start() {
    this.process = spawn(this.serverPath, [], {
      cwd: this.workspaceRoot,
      stdio: ['pipe', 'pipe', 'pipe'],
    });

    this.process.stdout.on('data', (chunk) => {
      this.handleStdoutChunk(chunk);
    });

    this.process.stderr.on('data', (chunk) => {
      this.stderrOutput.push(chunk.toString('utf8'));
    });

    this.process.on('exit', (code, signal) => {
      const message = `Lua Language Server beendet (code=${code ?? 'null'}, signal=${signal ?? 'null'}).`;
      const error = new Error(`${message}\n${this.stderrOutput.join('')}`.trim());
      for (const { reject } of this.pendingRequests.values()) {
        reject(error);
      }
      this.pendingRequests.clear();
    });

    await this.request('initialize', {
      processId: process.pid,
      clientInfo: {
        name: 'control-extension format-lua',
      },
      rootUri: this.workspaceUri,
      rootPath: this.workspaceRoot,
      workspaceFolders: [
        {
          uri: this.workspaceUri,
          name: path.basename(this.workspaceRoot),
        },
      ],
      initializationOptions: {
        changeConfiguration: true,
        trustByClient: true,
        useSemanticByRange: true,
        viewDocument: false,
      },
      capabilities: {
        workspace: {
          configuration: true,
          workspaceFolders: true,
        },
      },
      trace: 'off',
    });

    this.notify('initialized', {});
  }

  async stop() {
    if (!this.process) {
      return;
    }

    try {
      await this.request('shutdown', null);
    } catch {
      // Ignore shutdown failures if the server already exited.
    }

    try {
      this.notify('exit', null);
    } catch {
      // Ignore exit failures if stdio is already closed.
    }
  }

  async formatDocument(filePath, text) {
    const uri = pathToFileURL(filePath).href;

    this.notify('textDocument/didOpen', {
      textDocument: {
        uri,
        languageId: 'lua',
        version: 1,
        text,
      },
    });

    const edits = await this.request('textDocument/formatting', {
      textDocument: { uri },
      options: {
        tabSize: 4,
        insertSpaces: true,
        trimTrailingWhitespace: true,
        insertFinalNewline: true,
      },
    });

    this.notify('textDocument/didClose', {
      textDocument: { uri },
    });

    if (!Array.isArray(edits) || edits.length === 0) {
      return text;
    }

    return applyTextEdits(text, edits);
  }

  handleStdoutChunk(chunk) {
    this.stdoutBuffer = Buffer.concat([this.stdoutBuffer, chunk]);

    while (true) {
      const headerEnd = this.stdoutBuffer.indexOf('\r\n\r\n');
      if (headerEnd === -1) {
        return;
      }

      const headerText = this.stdoutBuffer.subarray(0, headerEnd).toString('ascii');
      const contentLengthMatch = /Content-Length:\s*(\d+)/i.exec(headerText);
      if (!contentLengthMatch) {
        throw new Error(`Ungueltiger LSP-Header: ${headerText}`);
      }

      const contentLength = Number.parseInt(contentLengthMatch[1], 10);
      const messageStart = headerEnd + 4;
      const messageEnd = messageStart + contentLength;
      if (this.stdoutBuffer.length < messageEnd) {
        return;
      }

      const body = this.stdoutBuffer.subarray(messageStart, messageEnd).toString('utf8');
      this.stdoutBuffer = this.stdoutBuffer.subarray(messageEnd);
      const message = JSON.parse(body);
      void this.handleMessage(message);
    }
  }

  async handleMessage(message) {
    if (message.method) {
      if (message.id !== undefined) {
        const result = await this.handleServerRequest(message.method, message.params);
        this.send({
          jsonrpc: '2.0',
          id: message.id,
          result,
        });
        return;
      }

      this.handleServerNotification(message.method, message.params);
      return;
    }

    const pendingRequest = this.pendingRequests.get(message.id);
    if (!pendingRequest) {
      return;
    }

    this.pendingRequests.delete(message.id);

    if (message.error) {
      pendingRequest.reject(new Error(JSON.stringify(message.error)));
      return;
    }

    pendingRequest.resolve(message.result);
  }

  async handleServerRequest(method, params) {
    if (method === 'workspace/configuration') {
      const items = params?.items ?? [];
      return items.map((item) => this.configuration[item.section] ?? null);
    }

    if (
      method === 'client/registerCapability' ||
      method === 'window/workDoneProgress/create' ||
      method === 'window/showMessageRequest' ||
      method === 'workspace/semanticTokens/refresh' ||
      method === 'workspace/diagnostic/refresh'
    ) {
      return null;
    }

    return null;
  }

  handleServerNotification(method, params) {
    if (method === 'window/logMessage' || method === 'window/showMessage') {
      const message = params?.message;
      if (message) {
        this.stderrOutput.push(`${message}\n`);
      }
    }
  }

  request(method, params) {
    const id = this.nextRequestId;
    this.nextRequestId += 1;

    return new Promise((resolve, reject) => {
      this.pendingRequests.set(id, { resolve, reject });
      this.send({
        jsonrpc: '2.0',
        id,
        method,
        params,
      });
    });
  }

  notify(method, params) {
    this.send({
      jsonrpc: '2.0',
      method,
      params,
    });
  }

  send(message) {
    this.process.stdin.write(encodeMessage(message));
  }
}

function computeLineOffsets(text) {
  const offsets = [0];
  for (let index = 0; index < text.length; index += 1) {
    if (text[index] === '\n') {
      offsets.push(index + 1);
    }
  }
  return offsets;
}

function positionToOffset(text, lineOffsets, position) {
  const lineStart = lineOffsets[position.line];
  if (lineStart === undefined) {
    throw new Error(`Ungueltige LSP-Position: Zeile ${position.line}`);
  }

  const lineEnd = position.line + 1 < lineOffsets.length ? lineOffsets[position.line + 1] : text.length;
  const lineText = text.slice(lineStart, lineEnd);
  let offset = lineStart;
  let remaining = position.character;

  for (const char of lineText) {
    if (remaining === 0) {
      break;
    }
    offset += char.length;
    remaining -= 1;
  }

  if (remaining > 0) {
    throw new Error(`Ungueltige LSP-Position: Zeichen ${position.character} in Zeile ${position.line}`);
  }

  return offset;
}

function applyTextEdits(text, edits) {
  const lineOffsets = computeLineOffsets(text);
  const normalizedEdits = edits
    .map((edit) => ({
      startOffset: positionToOffset(text, lineOffsets, edit.range.start),
      endOffset: positionToOffset(text, lineOffsets, edit.range.end),
      newText: edit.newText,
    }))
    .sort((left, right) => right.startOffset - left.startOffset || right.endOffset - left.endOffset);

  let updatedText = text;
  for (const edit of normalizedEdits) {
    updatedText = updatedText.slice(0, edit.startOffset) + edit.newText + updatedText.slice(edit.endOffset);
  }

  return updatedText;
}

function ensureLatin1Encodable(text, filePath) {
  for (let index = 0; index < text.length; index += 1) {
    if (text.charCodeAt(index) > 0xff) {
      throw new Error(`Formatierter Text fuer ${filePath} enthaelt Zeichen ausserhalb latin1.`);
    }
  }
}

async function formatFiles() {
  const workspaceRoot = process.cwd();
  const rawArgs = process.argv.slice(2);

  if (rawArgs.includes('--help') || rawArgs.includes('-h')) {
    printHelp();
    return;
  }

  const { extensionName, serverPath } = await findLuaLanguageServer();
  const settings = await loadWorkspaceSettings(workspaceRoot);
  const configuration = buildWorkspaceConfiguration(settings);
  const targetFiles = await resolveTargetFiles(rawArgs, workspaceRoot);

  if (targetFiles.length === 0) {
    console.log('Keine passenden Lua-Dateien gefunden.');
    return;
  }

  console.log(`Lua formatter: ${extensionName}`);
  console.log(`Dateien: ${targetFiles.length}`);

  const client = new LspClient({
    serverPath,
    workspaceRoot,
    configuration,
  });

  let changedFiles = 0;

  try {
    await client.start();

    for (const filePath of targetFiles) {
      const source = await fs.readFile(filePath, 'latin1');
      const formatted = await client.formatDocument(filePath, source);

      if (formatted === source) {
        continue;
      }

      ensureLatin1Encodable(formatted, filePath);
      await fs.writeFile(filePath, Buffer.from(formatted, 'latin1'));
      changedFiles += 1;
      console.log(`formatiert: ${path.relative(workspaceRoot, filePath)}`);
    }
  } finally {
    await client.stop();
  }

  console.log(`Fertig. Geaendert: ${changedFiles}/${targetFiles.length}`);
}

formatFiles().catch((error) => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
});
