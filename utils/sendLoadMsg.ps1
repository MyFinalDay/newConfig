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
$Console = Get-Process "powershell" | Sort-Object StartTime -Descending | Select-Object -First 1
$intPtr = $Console.MainWindowHandle
[User32Helper]::SetForegroundWindow($intPtr)

[System.Windows.Forms.SendKeys]::SendWait('"*\(*^_^*)/*"')

[System.Windows.Forms.SendKeys]::SendWait("{Enter}")

[System.Windows.Forms.SendKeys]::SendWait("E:\DataIn\gitRemoteProject\new_powershell_profile\loadProcess\loadProcess.ps1")

[System.Windows.Forms.SendKeys]::SendWait("{Enter}")

Start-Sleep -Seconds 4

[System.Windows.Forms.SendKeys]::SendWait("exit")

[System.Windows.Forms.SendKeys]::SendWait("{Enter}")

