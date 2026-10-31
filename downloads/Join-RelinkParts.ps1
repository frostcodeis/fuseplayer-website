$ErrorActionPreference = 'Stop'
$target = Join-Path $PSScriptRoot 'fuseplayer-1.0-lgpl-relink.zip'
if (Test-Path -LiteralPath $target) { throw 'Output ZIP already exists.' }
$parts = Get-Content (Join-Path $PSScriptRoot 'relink-parts.json') -Raw | ConvertFrom-Json
foreach ($p in $parts) {
 $file=Join-Path $PSScriptRoot $p.file
 if ((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant() -ne $p.sha256) { throw "Invalid or missing part: $($p.file)" }
}
$output=[IO.File]::Create($target)
try {
 foreach($p in $parts) {
  $partStream=[IO.File]::OpenRead((Join-Path $PSScriptRoot $p.file))
  try { $partStream.CopyTo($output) } finally { $partStream.Dispose() }
 }
} finally { $output.Dispose() }
Write-Output "Created $target. Extract it and read README.txt."