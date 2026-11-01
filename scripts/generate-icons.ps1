$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = Split-Path -Parent $PSScriptRoot
$source = [System.Drawing.Image]::FromFile((Join-Path $root 'assets/branding/wallet-tracker-money-bird-v3.png'))
function Save-Icon([string]$path, [int]$size) {
    $bitmap = [System.Drawing.Bitmap]::new($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.Clear([System.Drawing.ColorTranslator]::FromHtml('#F0FAF8'))
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.DrawImage($source, 0, 0, $size, $size)
        $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally { $graphics.Dispose(); $bitmap.Dispose() }
}
try {
    foreach ($entry in @{mdpi=48; hdpi=72; xhdpi=96; xxhdpi=144; xxxhdpi=192}.GetEnumerator()) {
        Save-Icon (Join-Path $root "android/app/src/main/res/mipmap-$($entry.Key)/ic_launcher.png") $entry.Value
    }
    foreach ($platform in @('ios', 'macos')) {
        $folder = Join-Path $root "$platform/Runner/Assets.xcassets/AppIcon.appiconset"
        $manifest = Get-Content (Join-Path $folder 'Contents.json') -Raw | ConvertFrom-Json
        foreach ($item in $manifest.images) {
            if ($item.filename) {
                $dimension = [double]($item.size.Split('x')[0]) * [double]($item.scale.TrimEnd('x'))
                Save-Icon (Join-Path $folder $item.filename) ([int]$dimension)
            }
        }
    }
    foreach ($entry in @{'favicon.png'=32; 'icons/Icon-192.png'=192; 'icons/Icon-512.png'=512; 'icons/Icon-maskable-192.png'=192; 'icons/Icon-maskable-512.png'=512}.GetEnumerator()) {
        $path = Join-Path $root "web/$($entry.Key)"
        if (Test-Path $path) { Save-Icon $path $entry.Value }
    }
    $pngPath = Join-Path $root 'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png'
    $png = [System.IO.File]::ReadAllBytes($pngPath)
    $writer = [System.IO.BinaryWriter]::new([System.IO.File]::Create((Join-Path $root 'windows/runner/resources/app_icon.ico')))
    try {
        $writer.Write([uint16]0); $writer.Write([uint16]1); $writer.Write([uint16]1)
        $writer.Write([byte]0); $writer.Write([byte]0); $writer.Write([byte]0); $writer.Write([byte]0)
        $writer.Write([uint16]1); $writer.Write([uint16]32)
        $writer.Write([uint32]$png.Length); $writer.Write([uint32]22); $writer.Write($png)
    } finally { $writer.Dispose() }
} finally { $source.Dispose() }
