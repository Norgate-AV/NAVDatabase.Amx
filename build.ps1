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

param (
    [Parameter(Mandatory = $false)]
    [string]
    $Path = "."
)

try {
    $Path = Resolve-Path $Path

    # Recursively search down the tree for all build.ps1 files
    $buildFiles = Get-ChildItem -Path module -Recurse -File -Filter *.ps1 |
    Where-Object { $_.FullName -notmatch ".history|.git$|node_modules" } |
    Where-Object { $_.FullName -match "build" }

    if (!$buildFiles) {
        Write-Host "No build.ps1 files found in $Path" -ForegroundColor Yellow
        exit
    }

    Write-Host "Building $($buildFiles.Count) projects..." -ForegroundColor Cyan

    foreach ($buildFile in $buildFiles) {
        $x = $buildFiles.IndexOf($buildFile) + 1
        Write-Host "Building project $x of $($buildFiles.Count)..." -ForegroundColor Cyan

        $percent = [math]::Round((($x - 1) / $buildFiles.Count) * 100, 2)
        Write-Host "[$percent%]" -ForegroundColor Cyan

        # Execute the build.ps1 file in it's local context
        Set-Location -Path $buildFile.Directory.FullName
        & $buildFile.FullName -Path $buildFile.Directory.FullName
        Set-Location $PSScriptRoot

        if ($LASTEXITCODE -ne 0) {
            Write-Host "$($buildFile.FullName) failed with exit code $($LASTEXITCODE)" -ForegroundColor Red
            exit 1
        }
    }

    $percent = [math]::Round(($x / $buildFiles.Count) * 100, 2)
    Write-Host "[$percent%]" -ForegroundColor Cyan
    Write-Host "Build complete!" -ForegroundColor Green
}
catch {
    Write-Host $_.Exception.GetBaseException().Message -ForegroundColor Red
    exit 1
}
