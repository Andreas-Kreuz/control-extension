import { cpSync, existsSync, mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, '..');
const pagesRoot = path.join(repoRoot, 'pages');
const luaDocsSourceRoot = path.join(repoRoot, 'lua');
const luaDocsTargetRoot = path.join(pagesRoot, 'lua');
const stagedRootMarkdown = [
  { source: 'project-docs/ARCHITECTURE.md', target: 'ARCHITECTURE.md' },
  { source: 'project-docs/CHANGELOG.md', target: 'CHANGELOG.md' },
  { source: 'CONTRIBUTING.md', target: 'CONTRIBUTING.md' },
  { source: 'project-docs/GOALS.md', target: 'GOALS.md' },
  { source: 'README.md', target: 'README.md' },
];
const stagedPaths = [];

const [, , command = 'build', ...extraArgs] = process.argv;

preparePagesSource();

const result = spawnSync('bundle', ['exec', 'jekyll', command, '--config', '_config.yml', ...extraArgs], {
  cwd: pagesRoot,
  stdio: 'inherit',
  shell: process.platform === 'win32',
  windowsHide: true,
});

cleanupPagesSource();

if (typeof result.status === 'number') {
  process.exit(result.status);
}

process.exit(1);

function preparePagesSource() {
  stageLuaDocs();
  stageRootMarkdown();
}

function stageLuaDocs() {
  rmSync(luaDocsTargetRoot, { force: true, recursive: true });
  stagedPaths.push(luaDocsTargetRoot);
  copyMarkdownTree(luaDocsSourceRoot, luaDocsTargetRoot);
}

function stageRootMarkdown() {
  for (const { source, target, rewriteOptions } of stagedRootMarkdown) {
    const sourcePath = path.join(repoRoot, source);
    if (!existsSync(sourcePath)) {
      continue;
    }

    const targetPath = path.join(pagesRoot, target);
    const content = readFileSync(sourcePath, 'utf8');
    mkdirSync(path.dirname(targetPath), { recursive: true });
    const options = rewriteOptions ?? { stripLeadingParent: source.startsWith('project-docs/') };
    writeFileSync(targetPath, rewriteMarkdownLinks(content, options), 'utf8');
    stagedPaths.push(targetPath);
  }
}

function copyMarkdownTree(sourceRoot, targetRoot) {
  for (const entry of readdirSync(sourceRoot, { withFileTypes: true })) {
    const sourcePath = path.join(sourceRoot, entry.name);
    const targetPath = path.join(targetRoot, entry.name);

    if (entry.isDirectory()) {
      copyMarkdownTree(sourcePath, targetPath);
      continue;
    }

    if (!entry.isFile() || !entry.name.toLowerCase().endsWith('.md')) {
      continue;
    }

    mkdirSync(path.dirname(targetPath), { recursive: true });
    const content = readFileSync(sourcePath, 'utf8');
    writeFileSync(targetPath, rewriteMarkdownLinks(content), 'utf8');
  }
}

function cleanupPagesSource() {
  if (process.env.CE_KEEP_STAGED_DOCS === '1') {
    return;
  }

  for (const targetPath of stagedPaths.reverse()) {
    rmSync(targetPath, { force: true, recursive: true });
  }
}

function rewriteMarkdownLinks(content, options = {}) {
  return content.replace(/\]\(([^)#?]+\.md)(#[^)]+)?\)/g, (match, target, anchor = '') => {
    if (/^[a-z]+:\/\//i.test(target)) {
      return match;
    }

    const normalized = target.replace(/\\/g, '/');
    const rewritten = rewriteMarkdownTarget(normalized, options);
    return `](${rewritten}${anchor})`;
  });
}

function rewriteMarkdownTarget(target, options = {}) {
  if (options.stripLeadingParent && target.startsWith('../')) {
    target = target.slice(3);
  }

  if (options.stripLeadingAiPrefix && target.startsWith('ai/')) {
    target = target.slice('ai/'.length);
  }

  if (target.startsWith('project-docs/')) {
    target = target.slice('project-docs/'.length);
  }

  target = target.replace('/project-docs/', '/');

  if (options.mapAgentsToAi && target === 'agents.md') {
    target = 'ai/agents.md';
  }

  if (target === 'README.md') {
    return './';
  }

  if (target === 'README_DEV.md') {
    return 'dev/';
  }

  if (target === 'DTO.md') {
    return 'dto/';
  }

  if (target === 'ARCHITECTURE.md') {
    return 'architecture/';
  }

  if (target.endsWith('/README.md')) {
    return target.slice(0, -'README.md'.length);
  }

  if (target.endsWith('/README_DEV.md')) {
    return `${target.slice(0, -'README_DEV.md'.length)}dev/`;
  }

  if (target.endsWith('/DTO.md')) {
    return `${target.slice(0, -'DTO.md'.length)}dto/`;
  }

  if (target.endsWith('/ARCHITECTURE.md')) {
    return `${target.slice(0, -'ARCHITECTURE.md'.length)}architecture/`;
  }

  if (target.endsWith('.md')) {
    return target;
  }

  return target;
}
