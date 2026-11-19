$ErrorActionPreference='Stop'
$target=Join-Path $PSScriptRoot 'fuseplayer-1.0-12-lgpl-relink.zip'
if(Test-Path -LiteralPath $target) { throw 'Output ZIP already exists.' }
$parts=Get-Content (Join-Path $PSScriptRoot 'relink-parts-1.0-12.json') -Raw | ConvertFrom-Json
foreach($part in $parts) {
 $file=Join-Path $PSScriptRoot $part.file
 if((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant() -ne $part.sha256) { throw 'Invalid or missing archive part.' }
}
$output=[IO.File]::Create($target)
try { foreach($part in $parts) { $input=[IO.File]::OpenRead((Join-Path $PSScriptRoot $part.file)); try { $input.CopyTo($output) } finally { $input.Dispose() } } } finally { $output.Dispose() }
Write-Output 'Archive joined. Extract it and read README.txt.'