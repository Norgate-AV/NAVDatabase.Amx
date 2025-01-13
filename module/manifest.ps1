$manifests = Get-ChildItem -File module/**/**/manifest.json | Where-Object { $_.FullName -notmatch "(.history|node_modules)" }

foreach ($manifest in $manifests) {
    $content = Get-Content $manifest -Raw | ConvertFrom-Json

    if (-not $content.PSObject.Properties["license"]) {
        $content | Add-Member -MemberType NoteProperty -Name license -Value "MIT"
    }

    if (-not $content.PSObject.Properties["files"]) {
        $content | Add-Member -MemberType NoteProperty -Name files -Value @()
    }

    if (-not $content.PSObject.Properties["dependencies"]) {
        $content | Add-Member -MemberType NoteProperty -Name dependencies -Value @()
    }

    $content.license = "MIT"
    $content.files = @(
        "src/*.axs",
        "src/*.tko",
        "lib/*.axi",
        "SymLink.ps1",
        "LICENSE",
        "README.md"
    )
    $content.dependencies = @(
        @{
            "version" = "^1.25.0"
            "url" = "github.com/Norgate-AV/NAVFoundation.Amx"
        }
    )

    $content | ConvertTo-Json | Set-Content $manifest -NoNewline
}
