$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot

$excelFile = Join-Path $root "source\NDGTS Dashboard Summer 2026.xlsx"
$outputFile = Join-Path $root "data\dashboard.csv"

Write-Host "Reading:"
Write-Host $excelFile

# ImportExcel reads XLSX directly -- Excel does not need to be installed
Import-Module ImportExcel

# ---------------------------------------------------------
# First proof of concept
# Read the All Team sheet.
# ---------------------------------------------------------

$rows = Import-Excel `
    -Path $excelFile `
    -WorksheetName "SU 2026 All Team"

Write-Host ""
Write-Host "Rows read: $($rows.Count)"

# For now, show us exactly what GitHub sees.
# We'll replace this with the normalization logic once
# we've confirmed the sheet structure.
Write-Host ""
Write-Host "Columns found:"

$rows[0].PSObject.Properties.Name |
    ForEach-Object {
        Write-Host "  $_"
    }

# Temporary raw CSV so we can inspect the result
New-Item `
    -ItemType Directory `
    -Force `
    -Path (Split-Path $outputFile) |
    Out-Null

$rows |
    Export-Csv `
        -Path $outputFile `
        -NoTypeInformation `
        -Encoding UTF8

Write-Host ""
Write-Host "Created:"
Write-Host $outputFile
