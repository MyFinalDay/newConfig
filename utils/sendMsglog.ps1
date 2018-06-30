Start-Process powershell -WindowStyle Maximized
Start-Sleep -Seconds 2

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
#1. 手动打开cmd（代表你的后台程序）
#2. 通过Get-process过滤出目标控制台程序
$Console = Get-Process "powershell" | Sort-Object StartTime -Descending | Select-Object -First 1
#3. 获取窗口句柄，并激活焦点
$intPtr = $Console.MainWindowHandle
[User32Helper]::SetForegroundWindow($intPtr)
#4. 输入你要执行的命令

[System.Windows.Forms.SendKeys]::SendWait('"*\(*^_^*)/*"')

[System.Windows.Forms.SendKeys]::SendWait("{Enter}")

[System.Windows.Forms.SendKeys]::SendWait(" . E:\DataIn\PowershellScriptData\psLib.ps1")

#5. 按回车执行命令
[System.Windows.Forms.SendKeys]::SendWait("{Enter}")

# wait
# [System.Windows.Forms.SendKeys]::SendWait("Start-Sleep -Seconds 2")

# [System.Windows.Forms.SendKeys]::SendWait("{Enter}")

# [System.Windows.Forms.SendKeys]::SendWait("^{v}")

[System.Windows.Forms.SendKeys]::SendWait("inf")

[System.Windows.Forms.SendKeys]::SendWait("{Enter}")

[System.Windows.Forms.SendKeys]::SendWait("lastPS")

[System.Windows.Forms.SendKeys]::SendWait("{Enter}")

[System.Windows.Forms.SendKeys]::SendWait("uploadTime")

[System.Windows.Forms.SendKeys]::SendWait("{Enter}")

Start-Sleep -Seconds 5

[System.Windows.Forms.SendKeys]::SendWait("exit")

[System.Windows.Forms.SendKeys]::SendWait("{Enter}")

