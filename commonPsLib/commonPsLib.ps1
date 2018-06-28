
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