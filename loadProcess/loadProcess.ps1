# load for work
. E:\DataIn\gitRemoteProject\new_powershell_profile\bin\psLib.ps1

# start program 
# $weChatDevTool = "C:\Users\Public\userSoft\weChatwebDev\cli.bat cli -o"
# Invoke-Expression $weChatDevTool

# Set-Content E:\DataIn\gitRemoteProject\new_powershell_profile\tmpCachedFile\tmpStartUpInfo.txt ([datetime]::Now)
Write-Host "start ..."

pg powershell

pg weChat
pg chrome

pg wechatdevtools
pg webstorm64

Start-Sleep -Seconds 3

Write-Host "`nend ..."

Stop-Process -Id $PID