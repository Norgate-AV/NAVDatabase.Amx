#!/usr/bin/env pwsh

<#
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Services Limited

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

[CmdletBinding()]

$directories = Get-ChildItem -Directory -Recurse | Where-Object { $_.FullName -notmatch "(.git$|.history|node_modules|vendor)" }
$paths = $directories | Get-ChildItem -File -Include "package.json" | Select-Object -ExpandProperty DirectoryName

foreach ($path in $paths) {
    $packageJson = Get-Content "$path/package.json" -Raw | ConvertFrom-Json
    $manifest = Join-Path -Path $path -ChildPath "manifest.json"

    $content = [ordered]@{
        "name"         = $packageJson.displayName ?? $packageJson.name ?? ""
        "description"  = $packageJson.description ?? ""
        "version"      = $packageJson.version ?? "1.0.0"
        "license"      = $packageJson.license ?? "MIT"
        "files"        = @(
            "src/*.axs",
            "src/*.tko",
            "lib/*.axi",
            "SymLink.ps1",
            "LICENSE",
            "README.md"
        )
        "repository"   = $packageJson.repository ?? @{
            "type" = "git"
            "url"  = ""
        }
        "bugs"         = $packageJson.bugs ?? @{
            "url" = ""
        }
        "dependencies" = @(
            @{
                "version" = "^1.25.0"
                "url"     = "github.com/Norgate-AV/NAVFoundation.Amx"
            }
        )
    }

    $content | ConvertTo-Json -Depth 10 | Set-Content $manifest && pnpm prettier --write $manifest
}
