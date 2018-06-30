
function saveCurrentPath () {
    # eg. saveCurrentPath 
    $Global:lastAccessPath = (Get-Location).Path
    $Global:lastAccessPath | clip
    $Global:lastAccessPath
}

function handleSpeicalSymbol {
    param(
        $pg
    )

    $process = $pg.ToString()
    $process
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
            $res = ($i).ToString('f0') + " Bytes"
        }

        $res
    }
}
function getPsSum ($process) {
    $processWs = (Get-Process $process | Measure-Object -Property WS -Sum).Sum
    $processWs = (logSizeHuman($processWs))
    $processWs
}

function changeCRLFToLF {
    # change windows path style to linux path style 
    param(
        [string]$path
    )

    if (Test-Path $path) {
        $path = '/' + $path.Replace('\', '/').replace(':', '') 
        $path | clip
        return $path
    }
    else {
        Write-Host "not a valid path!"
    }
    
}


function quickStartGitBash {
    Start-Process 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Git\Git Bash.lnk' -Verb runAs
    # wait 
    Start-Sleep -Milliseconds 600
    $path = (Get-Location).Path
    $path = changeCRLFToLF $path
    $path = "cd " + $path

    Add-Type @"
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
public class User32Helper
{
[DllImport("User32.dll")]
public static extern int SetForegroundWindow(IntPtr point);
}
"@ -ReferencedAssemblies @("System.Windows.Forms")
    Add-Type -AssemblyName System.Windows.Forms
    $Console = Get-Process "mintty" | Sort-Object StartTime -Descending | Select-Object -First 1
    # 获取窗口句柄，并激活焦点
    $intPtr = $Console.MainWindowHandle
    [User32Helper]::SetForegroundWindow($intPtr)
    # 输入要执行的命令
    [System.Windows.Forms.SendKeys]::SendWait($path)
    # 执行命令
    [System.Windows.Forms.SendKeys]::SendWait("{Enter}")
}