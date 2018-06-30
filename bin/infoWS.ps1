# ******************************************************************************** 
# some function
# ******************************************************************************** 

function  DegreeColorMap {
    param(
        [double]$percent
    ) 

    switch ($percent) {
        { $_ -le 20 } {
            [System.ConsoleColor]'White'
        }
        { $_ -gt 20 -and $_ -le 40 } {
            [System.ConsoleColor]'DarkGreen'
        }
        { $_ -gt 40 -and $_ -le 60 } {
            [System.ConsoleColor]'Green'
        }
        { $_ -gt 60 -and $_ -le 80 } {
            [System.ConsoleColor]'Blue'
        }
        { $_ -gt 80 -and $_ -le 100 } {
            [System.ConsoleColor]'DarkBlue'
        }
        Default {
            # [System.ConsoleColor]'White'
        }
    }
}
    

function getSortedPS {
    $result = (Get-Process | Sort-Object WorkingSet -Descending |
            Select-Object -First $args[0] |
            Format-Table @{Label = " Name"; Expression = {" " * 3 + $_.Name + " " * 1};
        }, Id, @{Label = "  WS (MB)  "; Expression = {[System.Math]::Truncate($_.WS / 1mb)}; alignment = "center";
        }, @{Name = "  StartTime  "; Expression = {($_.StartTime).ToString().split(' ')[1]}; alignment = "center";
        }, @{Label = "  Total Running time  "; Expression = {((Get-Date) - $_.StartTime).ToString().Split(".")[0]}; alignment = "center"; } 
    );
    # Write-Host "First " " $args ";
    $result
}

function getProWs {
    $ErrorActionPreference = "SilentlyContinue"
    $ws = (Get-Process -Name $args)
    $result = ($ws | ForEach-Object {$_.ws} | Measure-Object -sum).sum / 1mb;
    
    if ($ws -ne $null) {
        Write-Host "".PadLeft(5), $args, $result.ToString().Split('.')[0], "MB"
        Write-Host " "
    }
    $ErrorActionPreference = "Continue"
}

function getProCPU {
    $ErrorActionPreference = "SilentlyContinue"
    $result = (Get-Process -Name $args | ForEach-Object {$_.CPU} | Measure-Object -Sum).Sum;
    Write-Host "".PadLeft(5), $args, $result.ToString().Split('.')[0], "CPU"
    $ErrorActionPreference = "Continue"
}

function addToPath {
    $oldPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
    $oldPath += ";$args"
    [System.Environment]::SetEnvironmentVariable('Path', $oldPath, 'User') 
}

function computerInfo {
    $computerName = (Get-WmiObject -Class Win32_ComputerSystem).Name
    # or use: $env:COMPUTERNAME
    $computerVersion = (Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computerName).Version
    # or use: $computerVersion = (node -p os.release())

    $freeMem = (Get-WmiObject -Class Win32_OperatingSystem).FreePhysicalMemory / 1mb
    # or use: $freeMemo = (node -p "os.freemem()") / 1gb
    $totalMem = (Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1gb

    $freeMem = "{0:n3}" -f $freeMem
    # or use $totalMem = "{0:n3}" -f $totalMem
    $totalMem = $totalMem.ToString("f2")

    # Write-Host  "ComputerName: ".PadLeft(25) $computerName -ForegroundColor Green
    # Write-Host " ComputerVersion: ".PadLeft(25) $computerVersion
    # Write-Host "Username: ".PadLeft(25) $env:USERNAME
    Write-Host "FreeMemory: ".PadLeft(25) $freeMem "GB"
    # Write-Host " TotolMemory: ".PadLeft(25) $totalMem "GB"
}
function anothorComputerInfo () {
    # Counts of User Packages 
    Get-Package | Where-Object {$_.providerName -ne 'msi' -and $_.providerName -ne 'msu'} | Measure-Object
    
    # Chinese Packages
    Get-Package | Where-Object {[int][char]$_.name[0] -gt 255} | Where-Object {$_.providerName -ne 'msi'}

    # is64bit
    [System.Environment]::Is64BitOperatingSystem
    # or use node -p 'process.arch'

}


function getUpperChar {
    $text = 'this is a string here is some text with Uppercase letters' 
   
    $cnt = 0

    $position = foreach ($char in $text.ToCharArray()) {
        $cnt++
        if ([char]::IsUpper($char)) {
            $cnt
            break
        }

    }

    if ($position -eq $null) {
        'No Upper Characters!'
    }
    else {
        "First Uppercase Character at position $position"
        $text.Substring(0, $position) + " <<< " + $text.Substring($position)
    }
}

# failture
function getLeapYear ([datetime]$year) {

    $year = ($year).DayOfYear
    $ret = $year -eq $null
    "year is $year, $ret"

    foreach ($y in $year) {
        try {
            if (Get-Date -Date 2/29/$y) {
                Write-Host "$y is a leap year"
            }
        }
        catch {
            Write-Host "$y is not a leap year"   
        }
    }
}

function historyCount {
    Get-History | Group-Object CommandLine | Sort-Object Count -Descending | Select-Object -First $args[0] | Select-Object Count, Name
}

function extensionCount {
    Get-ChildItem $args[0] | Group-Object Extension | Sort-Object Count -Descending | Select-Object -First $args[1] 
}

function logSizeHuman ($i) {
    # beautify  
    if ($i -ne $null) {
        if ($i -gt 0.9Gb) {
            $res = ($i / 1Gb).ToString('f2') + " GB"
        }
        elseif ($i -gt 0.9Mb) {
            $res = ($i / 1Mb).ToString('f0') + " MB"
        }
        elseif ($i -gt 1Kb) {
            $res = ($i / 1Kb).ToString('f1') + " KB"
        }
        else {
            $res = ($i).ToString('f0') + " byte"
        }

        $res
    }
}
function getProcessWs ($i) {
    $ErrorActionPreference = "SilentlyContinue"
    return (Get-Process $i |  Measure-Object WS -Sum).Sum 
    $ErrorActionPreference = "Continue"
}
function logWs {
    $logObj = New-Object object
    $codeWs = getProcessWs code
    $atomWs = getProcessWs atom
    $chromeWs = getProcessWs chrome
    $firefoxWs = getProcessWs firefox
    $nodeWs = getProcessWs node
    $wechatdevtools = getProcessWs wechatdevtools

    if ($codeWs) {
        Add-Member -InputObject $logObj -Name "code" -Value (logSizeHuman($codeWs)) -MemberType NoteProperty
    }
    if ($atomWs) {
        Add-Member -InputObject $logObj -Name "atom" -Value (logSizeHuman($atomWs)) -MemberType NoteProperty
    }
    if ($chromeWs) {
        Add-Member -InputObject $logObj -Name "chrome" -Value (logSizeHuman($chromeWs)) -MemberType NoteProperty
    }
    if ($firefoxWs) {
        Add-Member -InputObject $logObj -Name "firefox" -Value (logSizeHuman($firefoxWs)) -MemberType NoteProperty
    }
    if ($nodeWs) {
        Add-Member -InputObject $logObj -Name "node" -Value (logSizeHuman($nodeWs)) -MemberType NoteProperty
    }
    if ($wechatdevtools) {
        Add-Member -InputObject $logObj -Name "wechatdevtools" -Value (logSizeHuman($wechatdevtools)) -MemberType NoteProperty
    }

    $logObj 
}
# ******************************************************************************** 
# some variables
# ******************************************************************************** 
# $dateArr = @((date), (Get-Date).DayOfWeek)
# $dateArr -join '  '
# -join ((Get-Date), '  ', (Get-Date).DayOfWeek)

$MultipleCnt = 100
$TotalDaysOfCurrentYear = 365
if ([datetime]::IsLeapYear([datetime]::Now.Year)) {
    $TotalDaysOfCurrentYear = 366
}
$DayOfYearPercent = [datetime]::Now.DayOfYear / $TotalDaysOfCurrentYear * $MultipleCnt
$TimeOfDayPercent = ([datetime]::Now.Hour + [datetime]::Now.Minute / 60) / 24 * $MultipleCnt
$SplitSymbol = '.';

[datetime]::Now.ToString('yyyy-MM-dd HH:mm:ss ddd')
Write-Host ''
Write-Host ($SplitSymbol * $DayOfYearPercent) -ForegroundColor (DegreeColorMap $DayOfYearPercent)
Write-Host ($SplitSymbol * $TimeOfDayPercent) -ForegroundColor (DegreeColorMap $TimeOfDayPercent)
Write-Host ($SplitSymbol * $MultipleCnt) -ForegroundColor DarkGray

Write-Host ''

logWs

getSortedPS 5

# New-Object string("*", 70)
Write-Host " "
computerInfo | Out-Host



<#

"You invoked this script by typing: " 
$MyInvocation.MyCommand
$MyInvocation.Line
$MyInvocation.ScriptLineNumber
$MyInvocation.PipelineLength
$MyInvocation.ScriptLineNumber
$MyInvocation.ScriptName

#>
# Get-Help dir -Examples | Out-String -OutVariable helpDirText | Out-Null


# getUpperChar -year 2004
Write-Host " "
historyCount 5

$Global:startInfoTime = (Get-Date)
# node E:\DataIn\NodejsData\testWebpack\testSmall\src\utils\studyEnglish\studyComputerEnglish.js
# New-Object string(" ", 10)
# Get-Content E:\DataIn\NodejsData\testWebpack\testSmall\src\utils\studyEnglish\words.js -Encoding UTF8 |
#     Get-Random -Count 5 -ErrorAction SilentlyContinue | ForEach-Object {"  " + $_}
# "`n`n"
