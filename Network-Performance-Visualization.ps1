Set-ExecutionPolicy -ExecutionPolicy  ByPass

. "$PSScriptRoot.\Data-Parser.ps1"
. "$PSScriptRoot.\Data-Processor.ps1"
. "$PSScriptRoot.\Data-Formatters.ps1"
. "$PSScriptRoot.\Excel-Plotter.ps1"

$XLENUM = New-Object -TypeName PSObject


function New-Visualization {
    <#
    .Description
    This cmdlet parses, processes, and produces a visualization of network performance data files generated by one of various 
    possible network performance tools. This tool is capable of visualizing data from the following tools:

        NTTTCP
        LATTE
        CTStraffic

    This tool can aggregate data over several iterations of test runs, and can be used to visualize comparisons
    between a baseline and test set of data.

    .PARAMETER NTTTCP
    Flag that sets NetData-Visualizer to run in NTTTCP mode

    .PARAMETER LATTE
    Flag that sets NetData-Visualizer to run in LATTE mode

    .PARAMETER CTStraffic
    Flag that sets NetData-Visualizer to run in CTStraffic mode

    .PARAMETER BaselineDir
    Path to directory containing network performance data files to be consumed as baseline data.

    .PARAMETER TestDir
    Path to directory containing network performance data files to be consumed as test data. Providing
    this parameter runs the tool in comparison mode.

    .PARAMETER SaveDir
    Path to directory where excel file will be saved with an auto-generated name if no SavePath provided

    .PARAMETER SavePath
    Path to exact file where excel file will be saved. 

    .SYNOPSIS
    Visualizes network performance data via excel tables and charts
    #>  
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ParameterSetName="NTTTCP")]
        [switch]$NTTTCP,

        [Parameter(Mandatory=$true, ParameterSetName="LATTE")]
        [switch]$LATTE,

        [Parameter(Mandatory=$true, ParameterSetName="CTStraffic")]
        [switch]$CTStraffic,

        [Parameter(Mandatory=$true, ParameterSetName = "NTTTCP")]
        [Parameter(Mandatory=$true, ParameterSetName = "LATTE")]
        [Parameter(Mandatory=$true, ParameterSetName = "CTStraffic")]
        [string]$BaselineDir, 

        [Parameter()]
        [string]$TestDir=$null,

        [Parameter()]
        [string]$SaveDir = "$home\Documents\PSreports",

        [Parameter()]
        [string]$SavePath = $none,

        [Parameter(ParameterSetName = "LATTE")]
        [int]$SubsampleRate = 50
    )
    
    Initialize-XLENUM

    $ErrorActionPreference = "Stop"

    # Save tool name
    $tool = ""
    if ($NTTTCP) {
        $tool = "NTTTCP"
    } 
    elseif ($LATTE) {
        $tool = "LATTE"
    } 
    elseif ($CTStraffic) {
        $tool = "CTStraffic"
    }

    # Parse Data
    $baselineRaw = Parse-Files -Tool $tool -DirName $BaselineDir
    $testRaw     = $null
    if ($TestDir) {
        $testRaw = Parse-Files -Tool $tool -DirName $TestDir
    } 

    $processedData = Process-Data -BaselineRawData $baselineRaw -TestRawData $testRaw

    [Array] $tables = @() 
    if (@("NTTTCP", "CTStraffic") -contains $tool) {
        $tables += "Raw Data"
        $tables += Format-RawData -DataObj $processedData -TableTitle $tool
        $tables += Format-Stats -DataObj $processedData -TableTitle $tool -Metrics @("min", "mean", "max", "std dev")
        $tables += Format-Quartiles -DataObj $processedData -TableTitle $tool
        $tables += Format-MinMaxChart -DataObj $processedData -TableTitle $tool
    } 
    elseif (@("LATTE") -contains $tool ) {
        $tables += Format-Distribution -DataObj $processedData -Title $tool -SubSampleRate $SubsampleRate
        $tables += Format-Stats -DataObj $processedData -TableTitle $tool
        $tables += Format-Histogram -DataObj $processedData -TableTitle $tool
    } 
    $tables  += "Percentiles" 
    $tables  += Format-Percentiles -DataObj $processedData -TableTitle $tool
    $fileName = Create-ExcelFile -Tables $tables -SaveDir $SaveDir -Tool $tool -SavePath $SavePath

    Write-Host "Created report at $filename"
}


##
# Initialize-XLENUM
# -----------------
# This function fills the content of the global object XLENUM with every enum value defined 
# by the Excel application. 
#
# Parameters
# ----------
# None
# 
# Return
# ------
# None
#
##
function Initialize-XLENUM {
    $xl = New-Object -ComObject Excel.Application -ErrorAction Stop
    $xl.Quit() | Out-Null

    $xl.GetType().Assembly.GetExportedTypes() | Where-Object {$_.IsEnum} | ForEach-Object {
        $enum = $_
        $enum.GetEnumNames() | ForEach-Object {
            $XLENUM | Add-Member -MemberType NoteProperty -Name $_ -Value $enum::($_) -Force
        }
    }
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl) | Out-Null
    [System.GC]::Collect() | Out-Null
    [System.GC]::WaitForPendingFinalizers() | Out-Null
}