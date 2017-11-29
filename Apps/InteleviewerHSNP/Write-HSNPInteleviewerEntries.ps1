$IHSNPC = Get-ItemProperty -Path 'HKCU:\SOFTWARE\SVHA\Switches' -ErrorAction SilentlyContinue | Select-Object InteleviewerHSNPCustomisationsInstalled

IF ($IHSNPC.InteleviewerHSNPCustomisationsInstalled -eq 1) {

    Write-Verbose "Values already exist"

}

ELSE {

    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\0" /v "/Default /Organization" /d "/Q/Scan" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\0" /v "/Url" /d "https:\\qscaniq.com.au" /f > $null

    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\1" /v "/Default /Organization" /d "/Q/X/R/Web /Images" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\1" /v "/Url" /d "https:\\qxrpacs.com.au" /f > $null

    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\2" /v "/Default /Organization" /d "/I-/M/E/D" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\2" /v "/Url" /d "https:\\pacs.i-med.com.au" /f > $null

    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\3" /v "/Default /Organization" /d "/Sunshine /Coast /Imaging" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\3" /v "/Url" /d "https:\\pacs.qld.i-med.com.au" /f > $null

    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\4" /v "/Default /Organization" /d "/B/P/I - /Brisbane /Private /Imaging" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\4" /v "/Url" /d "https:\\pacs.bpimaging.com.au" /f > $null
    
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\5" /v "/Default /Organization" /d "/Imaging /Queensland" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\5" /v "/Url" /d "https:\\pacs.imagingqueensland.com.au" /f > $null

    reg add "HKCU\Software\SVHA\Switches" /v "InteleviewerHSNPCustomisationsInstalled" /d "1" /f > $null

}