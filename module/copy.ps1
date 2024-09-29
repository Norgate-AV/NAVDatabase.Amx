$directories = Get-ChildItem -Directory -Recurse | Where-Object { $_.FullName -notmatch "(.git|.history|node_modules)" }
$files = $directories | Get-ChildItem -File -Include *.ps1 | Where-Object { $_.FullName -match "SymLink" }

# Loop through each file and replace the entire contents with the content from "./SymLink.ps1" in this directory
$content = Get-Content "./SymLink.ps1" -Raw

foreach ($file in $files) {
    Set-Content -Path $file.FullName -Value $content -NoNewline
}
