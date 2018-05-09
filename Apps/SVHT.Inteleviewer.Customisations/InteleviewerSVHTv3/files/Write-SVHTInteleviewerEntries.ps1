$ISVHTC = Get-ItemProperty -Path 'HKCU:\SOFTWARE\SVHA\Switches' -ErrorAction SilentlyContinue | Select-Object InteleviewerSVHTCustomisationsInstalled

IF ($ISVHTC.InteleviewerSVHTCustomisationsInstalled -eq 3) {

    Write-Verbose "Script has already run"

}

ELSE {

    Write-Verbose "Removing existing keys"

    reg delete "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks" /f > $null

    Write-Verbose "Adding keys"

    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\0" /v "/Default /Organization" /d "/Qscan /Radiology /Clinics" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\0" /v "/Url" /d "https:\\qscaniq.com.au" /f > $null

    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\1" /v "/Default /Organization" /d "/South /Burnett /Radiology" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\1" /v "/Url" /d "https:\\pacs.bpimaging.com.au" /f > $null

    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\2" /v "/Default /Organization" /d "/Alpenglow /Australia" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\2" /v "/Url" /d "https:\\pacs.alpenglow.com.au" /f > $null

    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\3" /v "/Default /Organization" /d "/Darling /Downs /Radiology" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\3" /v "/Url" /d "https:\\imaging.scr.com.au" /f > $null

    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\4" /v "/Default /Organization" /d "/Toowoomba /Diagnostic /Imaging" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\4" /v "/Url" /d "https:\\images.axisdi.com.au" /f > $null
    
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\5" /v "/Default /Organization" /d "/Granite /Belt /Diagnostic /Imaging" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\5" /v "/Url" /d "https:\\images.axisdi.com.au" /f > $null
    
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\6" /v "/Default /Organization" /d "/Exact /Radiology" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\6" /v "/Url" /d "https:\\exactradiology.com.au" /f > $null

    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\7" /v "/Default /Organization" /d "/Queensland /Xray" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\7" /v "/Url" /d "https:\\172.25.132.5" /f > $null

    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\8" /v "/Default /Organization" /d "/Queensland /Xray /Backup" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\8" /v "/Url" /d "https:\\qxrpacs.com.au" /f > $null

    reg add "HKCU\Software\SVHA\Switches" /v "InteleviewerSVHTCustomisationsInstalled" /d "3" /f > $null

}

$Mistake = Get-ItemProperty -Path 'HKCU:\SOFTWARE\SVHA\Switches' -ErrorAction SilentlyContinue | Select-Object InteleviewerSHVTCustomisationsInstalled

IF ($Mistake.InteleviewerSHVTCustomisationsInstalled) {

    Write-Verbose "Deleting incorrect key"
    
    reg delete HKCU\Software\SVHA\Switches /v InteleviewerSHVTCustomisationsInstalled /f > $null

}