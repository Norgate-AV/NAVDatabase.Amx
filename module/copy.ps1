$directories = Get-ChildItem -Directory -Recurse | Where-Object { $_.FullName -notmatch "(.git$|.history|node_modules)" }

$symlinkPaths = $directories | Get-ChildItem -File -Include *.ps1 | Where-Object { $_.FullName -match "SymLink" }
$archivePaths = $directories | Get-ChildItem -File -Include *.ps1 | Where-Object { $_.FullName -match "archive" }
$changelogPaths = $directories | Get-ChildItem -File -Include *.json | Where-Object { $_.FullName -match "changelogrc" }
$releasePaths = $directories | Get-ChildItem -File -Include *.json | Where-Object { $_.FullName -match "releaserc" }
$ciPaths = $directories | Get-ChildItem -File -Include *.yml | Where-Object { $_.FullName -match "main" }

# Loop through each file and replace the entire contents with the content from "./SymLink.ps1" in this directory
$symlinkContent = Get-Content "./SymLink.ps1" -Raw

foreach ($path in $symlinkPaths) {
    Set-Content -Path $path.FullName -Value $symlinkContent -NoNewline
}

# Loop through each file and replace the entire contents with the content from "./archive.ps1" in this directory
$archiveContent = Get-Content "./archive.ps1" -Raw

foreach ($path in $archivePaths) {
    Set-Content -Path $path.FullName -Value $archiveContent -NoNewline
}

# Loop through each file and replace the entire contents with the content from "./changelog.json" in this directory
$changelogContent = Get-Content "./.changelogrc.json" -Raw

foreach ($path in $changelogPaths) {
    Set-Content -Path $path.FullName -Value $changelogContent -NoNewline
}

# Loop through each file and replace the entire contents with the content from "./release.json" in this directory
$releaseContent = Get-Content "./.releaserc.json" -Raw

foreach ($path in $releasePaths) {
    Set-Content -Path $path.FullName -Value $releaseContent -NoNewline
}

# Loop through each file and replace the entire contents with the content from "./main.yml" in this directory
$ciContent = Get-Content "./main.yml" -Raw

foreach ($path in $ciPaths) {
    Set-Content -Path $path.FullName -Value $ciContent -NoNewline
}
