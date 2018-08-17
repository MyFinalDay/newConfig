. E:\DataIn\gitRemoteProject\new_powershell_profile\constantVariable\globalConstantVar.ps1
. E:\DataIn\gitRemoteProject\new_powershell_profile\commonPsLib\commonPsLib.ps1
# utils
. E:\DataIn\gitRemoteProject\new_powershell_profile\utils\search.ps1
. E:\DataIn\gitRemoteProject\new_powershell_profile\utils\translate.ps1
#

# Import-Alias
Invoke-Expression 'ipal E:\DataIn\gitRemoteProject\new_powershell_profile\setting\alias.csv -Force'

# set window title
$Host.UI.RawUI.WindowTitle = '*\(*^_^*)/*' + '    ' + (Get-Date)


enum ProgramEnum {
    firefox
    chrome
    weChat
    webstorm64
    powershell
    gvim
    cmd
    vim
    gitBash
    i_view64
    wechatdevtools
    BaiduNetdisk
}

# Function
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
    }
    else {
        Get-ChildItem
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

function ccl {
    Set-Location ..
    cl
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

function lastPS {
    # Get process last start-up ( has MainWindowTitle) eg. lastPS -> return 
    $ErrorActionPreference = "SilentlyContinue"
    Get-Process | Where-Object {$_.MainWindowTitle.ToString().Length -ne 0} | Sort-Object StartTime -Descending |
        Format-Table Name, Id, @{Label = "  WS (MB)  "; Expression = {logSizeHuman $_.WS}; alignment = "center";
    }, @{Name = "  StartTime  "; Expression = {($_.StartTime).ToString().split(' ')[1]}; alignment = "center";
    }, @{Label = "  Total Running time  "; Expression = {((Get-Date) - $_.StartTime).ToString().Split(".")[0]}; alignment = "center"; }, MainWindowTitle
    $ErrorActionPreference = "Continue"
}
function killLastPS_quick {
    # Stop-Process(only some special process use killLastPS for normal) eg. killPS powershell -> kill the last start-up powershell 
    param(
        [ProgramEnum]
        $pg
    )
    $process = handleSpeicalSymbol $pg

    $ErrorActionPreference = "SilentlyContinue"
    if ($process.ToLower() -eq 'explorer') {
        Get-Process $process | Where-Object {$_.MainWindowTitle -ne ''} | Sort-Object StartTime -Descending | Select-Object -First 1 | Stop-Process
    }
    else {
        Get-Process $process | Sort-Object StartTime -Descending | Select-Object -First 1 | Stop-Process 
    }
    $ErrorActionPreference = "Continue"
}

function zs {
    param(
        [ValidateSet("path", "reNamePinyin_quick", "reNamePinyin_recuresDeepPath2",
            "gTools", "eazydict", "testJs", "reStart", "searchResultPath", "phone",
            "tapd")]
        [string]
        $type
    )

    $paramStr = ($args -join '')
    $paramStrWithBlank = ($args -join ' ')
    $paramArr = $args

    switch ($type) {
        path { 
            # window path to git-bash path
            saveCurrentPath            
            $res = changeCRLFToLF  $Global:lastAccessPath
            $res = 'cd ' + $res | clip
        }

        reNamePinyin_quick {
            $item = ( Get-ChildItem $paramStr )
            $item | ForEach-Object { reNameWithPinying -item $_ -firstAlpha ( chineseToPinyin $_.ToString().Substring(0, 2) ) }
        }

        reNamePinyin_recuresDeepPath2 {
            $item = (Get-ChildItem -Recurse $paramStr)
            $item | ForEach-Object { reNameWithPinying -item $_ -firstAlpha ( chineseToPinyin $_.ToString().Substring(0, 2) ) }
        }

        gTools {
            pg gvim C:\Users\vipyo\gitRemoteProject\ElispNote\noteFile\tool_key.js
        }

        testJs {
            pg gvim E:\TmpReadOnlyData\waService.js
        }
        eazydict {
            # SimpleTranslate $paramStrWithBlank
            eazydict.cmd $paramArr
        }

        reStart {
            Stop-Process -Name $paramStr
            pg $paramStr
        }

        searchResultPath {
            pg gvim E:\DataIn\PowershellScriptData\tmpCacheFile\tmpSearchResultPath.js
        }

        phone {
            $Global:MyMsg.phone | clip
        }

        tapd {
            Start-Process https://www.tapd.cn/my_worktable?left_tree=1
            $url = "https://www.tapd.cn/worktable_ajax/get_top_nav_worktable_data?t=0.3755283616519416"
            Start-Sleep -Seconds 1 
            Start-Process $url
        }
        Default {}
    }
}


function uploadTime {
    # from computer start to current
    New-TimeSpan -End ([datetime]::Now) -Start (Get-Content E:\DataIn\gitRemoteProject\new_powershell_profile\tmpCachedFile\tmpStartUpInfo.txt) -ErrorAction SilentlyContinue | Format-Table 
}

function psLib {
    '. E:\DataIn\gitRemoteProject\new_powershell_profile\bin\psLib.ps1' | clip
}

function rmDistByShell {
    'rm -r `ls | grep -v *config*`' | clip
}

function ed {
    # if current path has only 1 directory, then cd & ls eg. ed
    $FileAndDirectory = Get-ChildItem | Measure-Object
    $directory = Get-ChildItem -Directory | Measure-Object

    $directoryCount = (Get-ChildItem -Directory . | Measure-Object).Count
    $fileCount = (Get-ChildItem -File . | Measure-Object).Count
    $lastAccessTimeFile = (Get-ChildItem -File . | Sort-Object LastAccessTime -Descending | Select-Object -First 1)
    $lastAccessTimeDirectory = (Get-ChildItem -Directory . | Sort-Object LastAccessTime -Descending | Select-Object -First 1)

    if (($FileAndDirectory.Count -eq 1) -and ($directory.Count -eq 1)) {
        Set-Location *
        Get-ChildItem
        Write-Host ""
        Write-Host "Directory count:".PadLeft(25) $directoryCount "   File Count:" $fileCount
        Write-Host "lastAccessFile:".PadLeft(25) $lastAccessTimeFile " lastAccessDirectory:" $lastAccessTimeDirectory
    }
    else {
        Write-Host ""
        Write-Host "Directory count:".PadLeft(25) $directoryCount "   File Count:" $fileCount
        Write-Host "lastAccessFile:".PadLeft(25) $lastAccessTimeFile " lastAccessDirectory:" $lastAccessTimeDirectory
    }
}

function slf {
    # start-process lastAccessFile
    $lastAccessTimeFile = (Get-ChildItem -File . | Sort-Object LastAccessTime -Descending | Select-Object -First 1)
    Start-Process $lastAccessTimeFile
}