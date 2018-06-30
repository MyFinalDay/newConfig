
function bdTranslate {
    # tranlate chinese <-> english 
    $word = ($args -join " ")
    
    $timeStamp = [Long]([Double]::Parse((Get-Date -UFormat %s)) * 1000)
    $appid = "2015063000000001"
    $key = "12345678"

    $tohash = $appid + $word + $timeStamp + $key
    $md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
    $utf8 = new-object -TypeName System.Text.UTF8Encoding
    $sign = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($tohash))).Replace("-", "").ToLower()


    $params = @{
        q     = $word;
        appid = $appid;
        salt  = $timeStamp;
        sign  = $sign;
    }
    $lngCheck = [System.Text.RegularExpressions.Regex]::Match($word, "[\u4e00-\u9fa5]").Success
    if ($lngCheck) {
        $params.Add("from", "zh")
        $params.Add("to", "en")
    }
    else {
        $params.Add("from", "en")
        $params.Add("to", "zh")
    }

    $querystring = ""
    $params.GetEnumerator() | ForEach-Object {$querystring += $_.Name + "=" + $_.Value + "&"}
    $url = "http://api.fanyi.baidu.com/api/trans/vip/translate?" + $querystring
    $rsp = Invoke-WebRequest $url | ConvertFrom-Json

    $rsp.trans_result[0].dst
}


function SimpleTranslate {
    $MaxCacheLineCnt = 160
    $TmpTranslateFilePath = 'E:\DataIn\gitRemoteProject\new_powershell_profile\tmpCachedFile\tmpTranslate.js'
    $OutOfCachePromptTxt = "`ntmp cached more than $MaxCacheLineCnt!`n"
    
    Write-Host " "
    $word = ($args -join " ")
    $res = bdTranslate $word
    if ([int[]][char[]]$word -ge 255) {
        $res | clip
        if ((Get-ChildItem $TmpTranslateFilePath| Select-String $res) -eq $null) {
            if ((Get-Content $TmpTranslateFilePath| Measure-Object).Count -lt $MaxCacheLineCnt) {
                addEnglishWords @($res, $word) $TmpTranslateFilePath
            }
            else {
                Write-Host $OutOfCachePromptTxt
            }
        }
    }
    else {
        $word | clip  
        if ((Get-ChildItem $TmpTranslateFilePath| Select-String $word) -eq $null) {
            if ((Get-Content $TmpTranslateFilePath| Measure-Object).Count -lt $MaxCacheLineCnt) {
                addEnglishWords @($word, $res) $TmpTranslateFilePath
            }
            else {
                Write-Host $OutOfCachePromptTxt
            }
        }
    }
    Write-Host "`t $res"
    Write-Host " "
    bdTranslate $res
    Write-Host " "
}