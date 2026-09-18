$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot

$excelFile = Join-Path $root "source\NDGTS_Dashboard_Excel_Master.xlsx"

$dataFolder = Join-Path $root "data"

$dashboardFile = Join-Path $dataFolder "dashboard.csv"
$narrativeFile = Join-Path $dataFolder "narrative.csv"
$briefingFile  = Join-Path $dataFolder "board_briefing.csv"
$indexRulesFile = Join-Path $dataFolder "index_rules.csv"
$metricDictionaryFile = Join-Path $dataFolder "metric_dictionary.csv"

Write-Host ""
Write-Host "========================================="
Write-Host "NDGTS Dashboard Export"
Write-Host "========================================="
Write-Host ""
Write-Host "Workbook:"
Write-Host $excelFile
Write-Host ""

Import-Module ImportExcel

# ---------------------------------------------------------
# Make sure output folder exists
# ---------------------------------------------------------

New-Item `
    -ItemType Directory `
    -Force `
    -Path $dataFolder |
    Out-Null


# ---------------------------------------------------------
# DASHBOARD EXPORT
# ---------------------------------------------------------

Write-Host "Reading Dashboard_Export..."

$dashboardRows = Import-Excel `
    -Path $excelFile `
    -WorksheetName "Dashboard_Export"

if (-not $dashboardRows) {
    throw "No rows found in Dashboard_Export."
}

$dashboardRows |
    Export-Csv `
        -Path $dashboardFile `
        -NoTypeInformation `
        -Encoding UTF8

Write-Host "  Rows: $($dashboardRows.Count)"
Write-Host "  Created: data/dashboard.csv"
Write-Host ""


# ---------------------------------------------------------
# NARRATIVE
# ---------------------------------------------------------

Write-Host "Reading Narrative..."

$narrativeRows = Import-Excel `
    -Path $excelFile `
    -WorksheetName "Narrative"

if (-not $narrativeRows) {
    throw "No rows found in Narrative."
}

$narrativeRows |
    Export-Csv `
        -Path $narrativeFile `
        -NoTypeInformation `
        -Encoding UTF8

Write-Host "  Rows: $($narrativeRows.Count)"
Write-Host "  Created: data/narrative.csv"
Write-Host ""


# ---------------------------------------------------------
# BOARD BRIEFING
# ---------------------------------------------------------

Write-Host "Reading Board_Briefing..."

$briefingRows = Import-Excel `
    -Path $excelFile `
    -WorksheetName "Board_Briefing"

if (-not $briefingRows) {
    throw "No rows found in Board_Briefing."
}

$briefingRows |
    Export-Csv `
        -Path $briefingFile `
        -NoTypeInformation `
        -Encoding UTF8

Write-Host "  Rows: $($briefingRows.Count)"
Write-Host "  Created: data/board_briefing.csv"
Write-Host ""

# ---------------------------------------------------------
# INDEX RULES
# ---------------------------------------------------------

Write-Host "Reading Metric_Calculation_Values..."

$indexRows = Import-Excel `
    -Path $excelFile `
    -WorksheetName "Metric_Calculation_Values"

if (-not $indexRows) {
    throw "No rows found in Metric_Calculation_Values."
}

$indexRows |
    Export-Csv `
        -Path $indexRulesFile `
        -NoTypeInformation `
        -Encoding UTF8

Write-Host "  Rows: $($indexRows.Count)"
Write-Host "  Created: data/index_rules.csv"
Write-Host ""


# ---------------------------------------------------------
# METRIC DICTIONARY
# ---------------------------------------------------------

Write-Host "Reading Metric_Dictionary..."

$dictionaryRows = Import-Excel `
    -Path $excelFile `
    -WorksheetName "Metric_Dictionary"

if (-not $dictionaryRows) {
    throw "No rows found in Metric_Dictionary."
}

$dictionaryRows |
    Export-Csv `
        -Path $metricDictionaryFile `
        -NoTypeInformation `
        -Encoding UTF8

Write-Host "  Rows: $($dictionaryRows.Count)"
Write-Host "  Created: data/metric_dictionary.csv"
Write-Host ""

# ---------------------------------------------------------
# DONE
# ---------------------------------------------------------

Write-Host "========================================="
Write-Host "Export complete"
Write-Host "========================================="
Write-Host ""
Write-Host "Created:"
Write-Host "  data/dashboard.csv"
Write-Host "  data/narrative.csv"
Write-Host "  data/board_briefing.csv"
Write-Host ""
