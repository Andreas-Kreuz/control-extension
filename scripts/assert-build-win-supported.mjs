if (process.platform === 'darwin') {
  console.error('Windows Electron packaging is not supported on macOS in this repository.');
  console.error('This project does not use Wine or Rosetta for Windows release builds.');
  console.error('Run `yarn build:exe` and `yarn build:release` on Windows instead.');
  process.exit(1);
}
