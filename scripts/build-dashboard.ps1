$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot

$excelFile = Join-Path $root "source\NDGTS Dashboard Summer 2026.xlsx"
$outputFile = Join-Path $root "data\dashboard.csv"

Import-Module ImportExcel

Write-Host ""
Write-Host "Reading:"
Write-Host $excelFile

# ---------------------------------------------------------
# Open workbook
# ---------------------------------------------------------

$package = Open-ExcelPackage -Path $excelFile

$sheet = $package.Workbook.Worksheets["SU 2026 All Team"]

if (-not $sheet) {
    throw "Worksheet 'SU 2026 All Team' was not found."
}

# ---------------------------------------------------------
# Metric configuration
#
# This is OUR dashboard configuration.
# Staff do not need to maintain these fields in Excel.
# ---------------------------------------------------------

$metricConfig = @{

    "Overdue A/R (30 Days)" = @{
        key     = "overdue_ar"
        section = "financial"
        unit    = "currency"
        order   = 1
        icon    = "fa-file-invoice-dollar"
    }

    "Down exhibits" = @{
        key     = "down_exhibits"
        section = "sustainability"
        unit    = "number"
        order   = 1
        icon    = "fa-screwdriver-wrench"
    }

    "Event Participation" = @{
        key     = "event_participation"
        section = "mission"
        unit    = "number"
        order   = 1
        icon    = "fa-users"
    }

    "Onsite Participation" = @{
        key     = "onsite_participation"
        section = "mission"
        unit    = "percent"
        order   = 2
        icon    = "fa-building"
    }

    "Offsite Participation" = @{
        key     = "offsite_participation"
        section = "mission"
        unit    = "percent"
        order   = 3
        icon    = "fa-bus"
    }

    "Facebook Views" = @{
        key     = "facebook_views"
        section = "sustainability"
        unit    = "number"
        order   = 2
        icon    = "fa-eye"
    }

    "Gallery Visitors" = @{
        key     = "gallery_visitors"
        section = "mission"
        unit    = "number"
        order   = 4
        icon    = "fa-person-walking"
    }

    "Memberships" = @{
        key     = "memberships"
        section = "sustainability"
        unit    = "number"
        order   = 3
        icon    = "fa-id-card"
    }
}

# ---------------------------------------------------------
# Build normalized dashboard rows
# ---------------------------------------------------------

$output = @()

# Metrics currently occupy rows 4 through 11.
# We'll actually scan farther so adding metrics later is easier.

for ($row = 4; $row -le $sheet.Dimension.End.Row; $row++) {

    $teamMember = $sheet.Cells[$row,1].Text.Trim()
    $team       = $sheet.Cells[$row,2].Text.Trim()
    $metric     = $sheet.Cells[$row,3].Text.Trim()
    $purpose    = $sheet.Cells[$row,4].Text.Trim()
    $source     = $sheet.Cells[$row,5].Text.Trim()
    $threshold  = $sheet.Cells[$row,6].Value
    $goal       = $sheet.Cells[$row,7].Value

    if ([string]::IsNullOrWhiteSpace($metric)) {
        continue
    }

    if (-not $metricConfig.ContainsKey($metric)) {

        Write-Host "Skipping unconfigured metric: $metric"
        continue
    }

    $config = $metricConfig[$metric]

    # Week columns H through W = 8 through 23

    for ($col = 8; $col -le 23; $col++) {

        # Row 3 contains week-ending date
        $snapshot = $sheet.Cells[3,$col].Value

        # Actual metric value
        $value = $sheet.Cells[$row,$col].Value

        if ($null -eq $snapshot) {
            continue
        }

        if ($null -eq $value -or $value -eq "") {
            continue
        }

        # -------------------------------------------------
        # Excel percentages are stored as decimals.
        #
        # 0.12 = 12%
        # -------------------------------------------------

        $outputValue = $value
        $outputGoal = $goal
        $outputThreshold = $threshold

        if ($config.unit -eq "percent") {

            if ($value -is [double] -or
                $value -is [decimal] -or
                $value -is [int]) {

                $outputValue = [math]::Round(
                    ([double]$value * 100),
                    2
                )
            }

            if ($goal -is [double] -or
                $goal -is [decimal] -or
                $goal -is [int]) {

                $outputGoal = [math]::Round(
                    ([double]$goal * 100),
                    2
                )
            }

            if ($threshold -is [double] -or
                $threshold -is [decimal] -or
                $threshold -is [int]) {

                $outputThreshold = [math]::Round(
                    ([double]$threshold * 100),
                    2
                )
            }
        }

        # -------------------------------------------------
        # Normalize date
        # -------------------------------------------------

        if ($snapshot -is [datetime]) {

            $snapshotDate =
                $snapshot.ToString("yyyy-MM-dd")

        }
        else {

            $snapshotDate =
                ([datetime]::FromOADate(
                    [double]$snapshot
                )).ToString("yyyy-MM-dd")
        }

        # -------------------------------------------------
        # Output record
        # -------------------------------------------------

        $output += [PSCustomObject]@{

            snapshot_date     = $snapshotDate

            section           = $config.section

            metric_key        = $config.key

            metric_label      = $metric

            value             = $outputValue

            goal              = $outputGoal

            threshold         = $outputThreshold

            unit              = $config.unit

            show_on_dashboard = "Y"

            sort_order        = $config.order

            icon              = $config.icon

            sub               = $purpose

            team              = $team

            team_member       = $teamMember

            source            = $source
        }
    }
}

Close-ExcelPackage $package -NoSave

# ---------------------------------------------------------
# Create output folder
# ---------------------------------------------------------

New-Item `
    -ItemType Directory `
    -Force `
    -Path (Split-Path $outputFile) |
    Out-Null

# ---------------------------------------------------------
# Write CSV
# ---------------------------------------------------------

$output |
    Sort-Object snapshot_date, section, sort_order |
    Export-Csv `
        -Path $outputFile `
        -NoTypeInformation `
        -Encoding UTF8

Write-Host ""
Write-Host "-----------------------------------------"
Write-Host "Dashboard conversion complete"
Write-Host "-----------------------------------------"

Write-Host "Records created: $($output.Count)"
Write-Host ""

$output |
    Group-Object metric_label |
    Sort-Object Name |
    ForEach-Object {

        Write-Host "$($_.Name): $($_.Count)"

    }

Write-Host ""
Write-Host "Created:"
Write-Host $outputFile
