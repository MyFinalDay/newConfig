. E:\DataIn\gitRemoteProject\new_powershell_profile\constantVariable\globalConstantVar.ps1
. E:\DataIn\gitRemoteProject\new_powershell_profile\commonPsLib\commonPsLib.ps1
# utils
. E:\DataIn\gitRemoteProject\new_powershell_profile\utils\search.ps1
# 


enum ProgramEnum {
    firefox
    chrome
    weChat
    webstorm64 
    powershell 
}
#
function sll {
    param(
        [string]
        $location,
        [ValidateSet("e", "g", "b", "s", "md", "ni",
            "np", "st", "slf", "groupExtension", "path",
            "saveCurrentPath")]
        [string]
        $openType
    ) 

    Set-Location $location
    $cnt = (Get-ChildItem | Measure-Object).Count
    $fileCnt = (Get-ChildItem -File | Measure-Object).Count
    $directoryCnt = (Get-ChildItem -Directory | Measure-Object).Count
    if ($cnt -gt 53) {
        Get-ChildItem | Sort-Object LastAccessTime -Descending | more
        Write-Host ''
        @($fileCnt, $directoryCnt, $cnt) -join '/'
    }
    else {
        Get-ChildItem | Sort-Object LastAccessTime -Descending 
        Write-Host ''
        @($fileCnt, $directoryCnt, $cnt) -join '/'
    }


    $fileName = ( Get-ChildItem -File . | Sort-Object Length | Select-Object -First 1 ).fullname

    function openFile {
        param(
            [ProgramEnum]
            $pg
        )

        $process = handleSpeicalSymbol $pg
        Start-Process $Global:programPathHash[$process] $fileName
    }

    switch ($openType) {
        'e' { explorer.exe . }
        'g' { pg gvim }

        'b' { quickStartGitBash }
        's' { Get-ChildItem | Sort-Object LastAccessTime -Descending | Select-Object -First 3 }

        'md' { New-Item -ItemType Directory -Name (genRandomStr) }
        'ni' { New-Item -ItemType File -Name (genRandomStr) }


        'np' { openFile([ProgramEnum]"notepad") }
        'st' { openFile([ProgramEnum]"sublime_text") }

        'slf' { slf }
        'groupExtension' {
            Get-ChildItem | Group-Object Extension | Sort-Object Count -Descending | Format-Table -Wrap
        }
        'path' {
            zs path
        }
        'saveCurrentPath' {
            saveCurrentPath
        }
        Default {}
    }
}
function cl() {
    # alias cd .. ; ls
    $directoryCount = (Get-ChildItem -Directory .. | Measure-Object).Count
    $fileCount = (Get-ChildItem -File .. | Measure-Object).Count
    $lastAccessTimeFile = (Get-ChildItem -File .. | Sort-Object LastAccessTime -Descending | Select-Object -First 1)
    $lastAccessTimeDirectory = (Get-ChildItem -Directory .. | Sort-Object LastAccessTime -Descending | Select-Object -First 1)

    Set-Location ..
    if ($fileCount -gt 53 -or $directoryCount -gt 53) {
        Get-ChildItem | Sort-Object LastAccessTime -Descending | more
        # Get-ChildItemColor | Sort-Object LastAccessTime -Descending | more
    }
    else {
        Get-ChildItem
        # Get-ChildItemColor
    }


    $logObj = New-Object object
    Add-Member -InputObject $logObj -Name "Directory count" -Value $directoryCount -MemberType NoteProperty
    Add-Member -InputObject $logObj -Name "File Count" -Value $fileCount  -MemberType NoteProperty
    Add-Member -InputObject $logObj -Name "lastAccessDirectory" -Value $lastAccessTimeDirectory -MemberType NoteProperty
    Add-Member -InputObject $logObj -Name "lastAccessFile" -Value $lastAccessTimeFile -MemberType NoteProperty

    Write-Host ""
    $logObj | Format-Table @{Label = "File count"; Expression = {$_."File Count"}; alignment = "center";
    }, @{Label = "Directory count"; Expression = {$_."Directory count"}; alignment = "center";
    }, @{Label = "lastAccessFile"; Expression = {$_."lastAccessFile"}; alignment = "center";
    }, @{Label = "lastAccessDirectory"; Expression = {$_."lastAccessDirectory"}; alignment = "center"; }
}


function wsAll {
    # Get process WorkingSet eg. wsAll firefox -> 632MB (only some specail process, use [getWsAllNormal ] for another process)
    param(
        [ProgramEnum]
        $pg
    )

    function isProcessRunning {
        param(
            [string]
            $process
        )
        
        if ( ( Get-Process | Where-Object {$_.Name -eq $process} ) -ne $null ) {
            $true
        }
        else {
            $false
        }
    }

    $process = handleSpeicalSymbol $pg
    if ( isProcessRunning $process ) {
        $processWs = getPsSum($process)
        $processWs
    }
    else {
        $maybeRes = [enum]::GetNames([ProgramEnum]) |
            Where-Object {$_.toLower().StartsWith($process.Substring(0, 1).toLower())} |
            Where-Object {isProcessRunning $_}
        if ( $maybeRes -ne $null ) {
            Write-Host "`nDo you mean?`n"
            $maybeRes
            Write-Host ""
        }
        else {
            Write-Host "`nNo such process!`n"
        }
    }
}

function wsAllNoraml {
    # Get process WorkingSet eg. wsAllNoraml firefox -> 632MB 5
    param(
        [string]
        $process 
    )
    $processWs = getPsSum($process)
    $processCnt = ( Get-Process $process | Measure-Object ).Count
    $processWs
    $processCnt
}

function pg {
    # pg gvim
    param(
        [ProgramEnum]
        $pg,
        [string]
        $filename
    )

    $process = handleSpeicalSymbol $pg

    if ($filename) {
        if (Test-Path $filename) {
            $filename = (Get-Item $filename).FullName
        }
        elseif ($filename -eq '1') {
            $filename = ( Get-ChildItem -File . | Sort-Object LastAccessTime -Descending | Select-Object -First 1 ).FullName
        }
    }

    switch ($process) {
        gvim { 
            if ($filename) {
                Start-Process $Global:programPathHash[$process] $filename -WindowStyle Maximized 
            }
            else {
                Start-Process $Global:programPathHash[$process] -WindowStyle Maximized 
            }
        }
        gitBash { 
            Start-Process $Global:programPathHash[$process] -Verb runAs
            $path = (Get-Location).Path
            $path = changeCRLFToLF $path
            $path = "cd " + $path
            $path | clip.exe
        }
        powershell { Start-Process $Global:programPathHash[$process] -Verb runAs }
        powershell_ise { Start-Process $Global:programPathHash[$process] -Verb runAs }
        firefox {
            if ($filename) {
                Start-Process $Global:programPathHash[$process] $filename 
            }
            else {
                Start-Process $Global:programPathHash[$process] 
            }
        }
        Default { Start-Process $Global:programPathHash[$process] }
    }
}