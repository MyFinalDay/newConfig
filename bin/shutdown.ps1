
Get-Date

start-Sleep -Seconds 1

"`t" + "*" * 100
"`n"
"`t" + "*" * 100
"`n"

Set-Content E:\DataIn\gitRemoteProject\new_powershell_profile\tmpCachedFile\tmpShutdownInfo.txt ([datetime]::Now)

. E:\DataIn\gitRemoteProject\new_powershell_profile\utils\sendMsglog.ps1

Write-Host "`nShutdown..."


Write-Host "kill..."
Stop-Process -Name ONENOTEM, i_view64, ConEmuC64, ONENOTE, Code, git-cmd, bash, PxCook, firefox, chrome, EgretWing, wechat*, webstorm64, emacs, git-bash, ConEmu64, KanKan, FSViewer -ErrorAction SilentlyContinue

shutdown.exe -s -t 8
start-Sleep -Seconds 7
Stop-Process -Name powershell, powershell_ise

