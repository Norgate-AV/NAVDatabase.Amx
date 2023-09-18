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

param(
    [Parameter(Mandatory = $false)]
    [string]
    $Folder = "."
)

try {
    $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    $FullPath = Resolve-Path "$Folder"
    Write-Host "⏳ Checking symlinks at 📂 $FullPath including subfolders..."

    [int] $NumTotal = [int] $NumBroken = 0
    
    Get-ChildItem $FullPath -Recurse  | Where-Object { $_.Attributes -match "ReparsePoint" } | ForEach-Object {
        $Symlink = $_.FullName
        $Target = ($_ | Select-Object -ExpandProperty Target -ErrorAction Ignore)

        if (!$Target) {
            return
        }

        $NumTotal++
        $item = Get-Item $Target -ErrorAction Ignore

        if ($item) {
            return
        }

        $NumBroken++
        Write-Host "Symlink $Symlink to: $Target seems broken (#$NumBroken)" -ForegroundColor Yellow

        Remove-Item $Symlink -Force
    }

    [int] $Elapsed = $StopWatch.Elapsed.TotalSeconds

    if ($NumTotal -eq 0) {
        Write-Host "✔️  No symlink found at 📂 $FullPath in $Elapsed sec"
        return
    }

    Write-Host "📂 $FullPath contains $NumTotal symlinks."
    Write-Host "✔️  Found $NumBroken broken symlink(s) at 📂 $FullPath in $Elapsed sec"

    exit $NumBroken
}
catch {
    Write-Host "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])" -ForegroundColor Red
    exit 1
}