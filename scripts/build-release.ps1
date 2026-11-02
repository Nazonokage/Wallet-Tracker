$ErrorActionPreference = 'Stop'
$project = Split-Path -Parent $PSScriptRoot
Push-Location -LiteralPath $project
try {
    & flutter build apk --release
    if ($LASTEXITCODE -ne 0) { throw 'Release build failed. No named APK was produced.' }
    $source = Join-Path $project 'build/app/outputs/flutter-apk/app-release.apk'
    $destination = Join-Path $project 'build/app/outputs/flutter-apk/Wallet-Tracker.apk'
    Copy-Item -LiteralPath $source -Destination $destination -Force
    Get-FileHash -LiteralPath $destination -Algorithm SHA256
    Write-Output "Release APK: $destination"
} finally { Pop-Location }
