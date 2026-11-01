<#
.SYNOPSIS
Builds and installs an update while preserving Android application data.
.DESCRIPTION
Uses adb install -r only. Stops on any build/install failure, including signing
mismatches. Never falls back to uninstall, pm clear, or changing the package ID.
Keep the same signing key for all updates. For a new phone, restore Android backup
or import the CSV/Excel backup from Settings after installation.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$DeviceId,
    [switch]$Release,
    [switch]$SkipBuild,
    [string]$AdbPath
)

$ErrorActionPreference = 'Stop'
$projectDirectory = Split-Path -Parent $PSScriptRoot
$buildMode = if ($Release) { 'release' } else { 'debug' }
$apkPath = Join-Path $projectDirectory "build/app/outputs/flutter-apk/app-$buildMode.apk"

if (-not $PSCmdlet.ShouldProcess($(if ($DeviceId) { $DeviceId } else { 'connected Android device' }), "Build/install $buildMode APK with application data retained")) { return }

if (-not $SkipBuild) {
    Push-Location -LiteralPath $projectDirectory
    try {
        & flutter build apk "--$buildMode"
        if ($LASTEXITCODE -ne 0) { throw 'Build failed. No installation was attempted.' }
    } finally { Pop-Location }
}
if (-not (Test-Path -LiteralPath $apkPath -PathType Leaf)) { throw "APK not found: $apkPath" }

if (-not $AdbPath) {
    $adbCommand = Get-Command adb -ErrorAction SilentlyContinue
    if ($adbCommand) { $AdbPath = $adbCommand.Source }
    else {
        $sdkDirectory = $env:ANDROID_SDK_ROOT
        if (-not $sdkDirectory) { $sdkDirectory = $env:ANDROID_HOME }
        if (-not $sdkDirectory) {
            $propertiesPath = Join-Path $projectDirectory 'android/local.properties'
            if (Test-Path -LiteralPath $propertiesPath) {
                $sdkLine = Get-Content -LiteralPath $propertiesPath | Where-Object { $_ -match '^sdk\.dir=' } | Select-Object -First 1
                if ($sdkLine) { $sdkDirectory = $sdkLine.Substring(8).Replace('\\', '\').Replace('\:', ':') }
            }
        }
        if ($sdkDirectory) { $AdbPath = Join-Path $sdkDirectory 'platform-tools/adb.exe' }
    }
}
if (-not $AdbPath -or -not (Test-Path -LiteralPath $AdbPath -PathType Leaf)) {
    throw 'ADB not found. Supply -AdbPath or configure the Android SDK.'
}
$deviceArguments = @()
if ($DeviceId) { $deviceArguments = @('-s', $DeviceId) }
& $AdbPath @deviceArguments install -r $apkPath
if ($LASTEXITCODE -ne 0) {
    throw 'Update rejected. The existing app and its data were left in place. Use the same signing key and package ID; do not uninstall to fix a signing mismatch. Export a backup from the existing app before changing signing keys.'
}
Write-Output 'Installed with existing data retained. Open Wallet Tracker on your phone.'
