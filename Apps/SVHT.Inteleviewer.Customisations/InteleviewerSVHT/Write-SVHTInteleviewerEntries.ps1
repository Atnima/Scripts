$ISVHTC = Get-ItemProperty -Path 'HKCU:\SOFTWARE\SVHA\Switches' -ErrorAction SilentlyContinue | Select InteleviewerSHVTCustomisationsInstalled

IF ($ISVHTC.InteleviewerSHVTCustomisationsInstalled -eq 1) {

    Write-Verbose "Values already exist"

}

ELSE {

    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\0" /v "/Default /Organization" /d "/Qscan /Radiology /Clinics" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\0" /v "/Url" /d "https:\\qscaniq.com.au" /f > $null

    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\1" /v "/Default /Organization" /d "/South /Burnett /Radiology" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\1" /v "/Url" /d "https:\\pacs.bpimaging.com.au" /f > $null

    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\2" /v "/Default /Organization" /d "/Alpenglow /Australia" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\2" /v "/Url" /d "https:\\pacs.alpenglow.com.au" /f > $null

    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\3" /v "/Default /Organization" /d "/Darling /Downs /Radiology" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\3" /v "/Url" /d "https:\\imaging.scr.com.au" /f > $null

    reg add "HKCU\Software\SVHA\Switches" /v "InteleviewerSHVTCustomisationsInstalled" /d "1" /f > $null

}