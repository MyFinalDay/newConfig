function ns {
    # net search
    param(
        [ValidateSet("", "bd", "g2", "bk", "segmentfault", "stackoverflow", "bd_FileType",
            "searchBookmarksOfChrome", "github", "googleTranslate", "baiduTranslate",
            "bingTranslate", "codepen", "wiki", "youdaoTranslate", "quora", "serverfault",
            "zstackexchange", "iconfont" )]
        [string]
        $net
    ) 

    $keyWord = $args -join " "
    if (![string]::IsNullOrEmpty($keyWord)) {
        # $keyWord = [System.Web.HttpUtility]::UrlEncode($keyWord) ( is Error !)
        $keyWord = [uri]::EscapeDataString($keyWord)
    }

    switch ($net) {
        g2 { Start-Process https://www.google.com/search?q=$keyWord }
        bk {
            if ($keyWord -ne '') {
                start-process https://baike.baidu.com/item/$keyWord
            }
            else {
                Start-Process https://baike.baidu.com/
            }
        }
        segmentfault { Start-Process https://segmentfault.com/search?q=$keyWord }
        stackoverflow {
            if ($keyWord -ne '') {
                Start-Process https://stackoverflow.com/search?q=$keyWord
            }
            else {
                Start-Process https://stackoverflow.com/
            }
        }
        bd { Start-Process https://www.baidu.com/s?wd=$keyWord }
        github { Start-Process https://github.com/search?q=$keyWord }
        searchBookmarksOfChrome {
            $keyWord = $keyWord.ToLower()
            $bookmarks = bookmarksOfChrome | Select-Object -Index 1
            $result = $bookmarks | Where-Object {$_.Name.ToLower() -like "*$keyWord*"}

            ($result | Select-Object -First 1 | Select-Object url).url | clip.exe
            $result 
        }
        googleTranslate {
            if ([int][char]$keyWord[0] -le 255) {
                Start-Process "https://translate.google.cn/#en/zh-CN/$keyWord"
            }
            else {
                Start-Process "https://translate.google.cn/#zh-CN/en/$keyWord"
            }
        }
        baiduTranslate {
            if ([int][char]$keyWord[0] -le 255) {
                Start-Process "http://fanyi.baidu.com/#en/zh/$keyword"
            }
            else {
                Start-Process "http://fanyi.baidu.com/#zh/en/$keyword"
            }
        }
        codepen {
            Start-Process https://codepen.io/search/pens?q=$keyWord
        }
        bingTranslate {
            Start-Process https://cn.bing.com/translator/
        }
        wiki {
            Start-Process https://en.wikipedia.org/wiki/$keyWord
        }
        youdaoTranslate {
            Start-Process http://dict.youdao.com/search?q=$keyWord
        }
        quora {
            Start-Process https://www.quora.com/search?q=$keyword
        }
        serverfault {
            Start-Process https://serverfault.com/search?q=$keyWord
        }
        zstackexchange {
            Start-Process https://stackexchange.com/search?q=$keyWord
        }
        iconfont {
            Start-Process http://www.iconfont.cn/search/index?q=$keyword
        }

        Default { ns bd  }
    }
}