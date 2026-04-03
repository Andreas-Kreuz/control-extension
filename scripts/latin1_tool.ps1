[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('read', 'write', 'replace', 'check')]
    [string]$Action,

    [Parameter(Mandatory = $true)]
    [string]$Path,

    [string]$Text,

    [string]$From,

    [string]$To
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
$replacementCharBytes = [byte[]](0xEF, 0xBF, 0xBD)

function Resolve-RepoFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RelativePath
    )

    $candidate = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $RelativePath))
    if (-not $candidate.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Path is outside the repository: $RelativePath"
    }

    $relativeUri = New-Object System.Uri($repoRoot.TrimEnd('\') + '\')
    $candidateUri = New-Object System.Uri($candidate)
    $repoRelative = $relativeUri.MakeRelativeUri($candidateUri).ToString().Replace('/', '\')

    $isLuaFile = [System.IO.Path]::GetExtension($candidate).Equals('.lua', [System.StringComparison]::OrdinalIgnoreCase)
    $lowerRelative = $repoRelative.Replace('\', '/').ToLowerInvariant()
    $isExchangeFile = $lowerRelative.StartsWith('lua/lua/ce/databridge/exchange/')
    $isMapFixture = $lowerRelative -match '^apps/web-app/cypress/fixtures/[^/]+/[^/]+\.json$'
    if (-not ($isLuaFile -or $isExchangeFile -or $isMapFixture)) {
        throw "Only *.lua files, files below lua/LUA/ce/databridge/exchange, and files below apps/web-app/cypress/fixtures/*/*.json are allowed: $repoRelative"
    }

    return @{
        FullPath = $candidate
        Relative = $repoRelative
    }
}

function Read-Latin1Text {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FullPath
    )

    if (-not [System.IO.File]::Exists($FullPath)) {
        throw "File does not exist: $FullPath"
    }

    return [System.IO.File]::ReadAllText($FullPath, $latin1)
}

function Read-Latin1Bytes {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FullPath
    )

    if (-not [System.IO.File]::Exists($FullPath)) {
        throw "File does not exist: $FullPath"
    }

    return [System.IO.File]::ReadAllBytes($FullPath)
}

function Test-ReplacementBytes {
    param(
        [Parameter(Mandatory = $true)]
        [byte[]]$Data
    )

    for ($i = 0; $i -le $Data.Length - $replacementCharBytes.Length; $i++) {
        $match = $true
        for ($j = 0; $j -lt $replacementCharBytes.Length; $j++) {
            if ($Data[$i + $j] -ne $replacementCharBytes[$j]) {
                $match = $false
                break
            }
        }

        if ($match) {
            return $true
        }
    }

    return $false
}

function Write-Latin1Text {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FullPath,

        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    [System.IO.File]::WriteAllText($FullPath, $Value, $latin1)
    $writtenBytes = [System.IO.File]::ReadAllBytes($FullPath)
    if (Test-ReplacementBytes -Data $writtenBytes) {
        throw "Replacement character bytes detected after write: $FullPath"
    }
}

$file = Resolve-RepoFile -RelativePath $Path

switch ($Action) {
    'read' {
        Write-Output (Read-Latin1Text -FullPath $file.FullPath)
    }

    'write' {
        if ($null -eq $Text) {
            throw "-Text is required for action 'write'."
        }

        Write-Latin1Text -FullPath $file.FullPath -Value $Text
        Write-Output ("OK: wrote {0}" -f $file.Relative)
    }

    'replace' {
        if ($null -eq $From -or $null -eq $To) {
            throw "-From and -To are required for action 'replace'."
        }

        $content = Read-Latin1Text -FullPath $file.FullPath
        if (-not $content.Contains($From)) {
            throw "Replacement source not found in $($file.Relative)."
        }

        $updated = $content.Replace($From, $To)
        Write-Latin1Text -FullPath $file.FullPath -Value $updated
        Write-Output ("OK: updated {0}" -f $file.Relative)
    }

    'check' {
        $data = Read-Latin1Bytes -FullPath $file.FullPath
        if (Test-ReplacementBytes -Data $data) {
            throw "ENCODING BROKEN: $($file.Relative)"
        }

        Write-Output ("OK: {0}" -f $file.Relative)
    }
}
