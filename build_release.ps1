param (
    [string]$Destination = "G:\My Drive\APKs",
    [string]$ApkName = "storemate_release.apk"
)

Write-Host "Building Flutter release APK..." -ForegroundColor Cyan
flutter build apk --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed! Aborting sync." -ForegroundColor Red
    exit $LASTEXITCODE
}

$source = "build\app\outputs\flutter-apk\app-release.apk"
$target = Join-Path -Path $Destination -ChildPath $ApkName

Write-Host "Build successful. Syncing to Google Drive at $target..." -ForegroundColor Cyan

if (Test-Path $Destination) {
    Copy-Item -Path $source -Destination $target -Force
    Write-Host "Sync complete!" -ForegroundColor Green
} else {
    Write-Host "Error: Destination path '$Destination' not found. Is Google Drive mounted?" -ForegroundColor Red
}
