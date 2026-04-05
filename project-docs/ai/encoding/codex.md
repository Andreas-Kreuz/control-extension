# Codex: Editing Latin1 Files

## NEVER use Edit/Write tools on Latin1 files with umlauts

Edit and Write tools write UTF-8 back. This corrupts all latin1 bytes in the entire file — even unchanged lines. `ü` (0xFC) becomes U+FFFD (0xEF 0xBF 0xBD), which is irreparable.

New `.lua` files without umlauts (pure ASCII) may be created with Write.

## Preferred: `scripts/latin1_tool.ps1`

Actions: `read`, `write`, `replace`, `check`

## Fallback: Byte-Level Python

```python
with open('datei.lua', 'rb') as f:
    data = f.read()
data = data.replace(b'alter ascii text', b'neuer ascii text')
with open('datei.lua', 'wb') as f:
    f.write(data)
```

- Replacements must remain ASCII (0x00–0x7F) — never umlauts in replacement strings
- Verify: `python -c "d=open('datei.lua','rb').read(); assert b'\xef\xbf\xbd' not in d, 'ENCODING BROKEN'"`

## Shell commands for Latin1

- Prefer Windows PowerShell 5.1 for shell commands in this repo
- Always set encoding explicitly for `.lua` file operations
- PowerShell 5.1 does not support `-Encoding Latin1`:
  - Read: `[System.IO.File]::ReadAllText($path, [System.Text.Encoding]::GetEncoding('iso-8859-1'))`
  - Write: `[System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::GetEncoding('iso-8859-1'))`
- Other files: `Get-Content -Encoding UTF8` / `Set-Content -Encoding UTF8`
