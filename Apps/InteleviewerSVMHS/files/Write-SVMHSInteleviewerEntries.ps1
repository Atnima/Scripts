$ISVMHSC = Get-ItemProperty -Path 'HKCU:\SOFTWARE\SVHA\Switches' -ErrorAction SilentlyContinue | Select-Object InteleviewerSVMHSCustomisationsInstalled

IF ($ISVMHSC.InteleviewerSVMHSCustomisationsInstalled -eq 1) {

    Write-Verbose "Values already exist"

}

ELSE {

    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\0" /v "/Default /Organization" /d "/Castlereagh /Imaging" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\0" /v "/Url" /d "https:\\mypatients.casimaging.com" /f > $null

    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\1" /v "/Default /Organization" /d "/I/M/E/D /Network (/R/I/L)" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\1" /v "/Url" /d "https:\\pacs.ril.com.au" /f > $null

    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\2" /v "/Default /Organization" /d "/Mater /Imaging" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\2" /v "/Url" /d "https:\\intelerad.mater-imaging.com.au" /f > $null

    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\3" /v "/Default /Organization" /d "/North/Coast /Radiology" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\3" /v "/Url" /d "https:\\iv.ncrad.com" /f > $null

    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\4" /v "/Default /Organization" /d "/North/Shore /Radiology" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\4" /v "/Url" /d "https:\\imaging.northshoreradiology.com.au" /f > $null
    
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\5" /v "/Default /Organization" /d "/P/R/P /Diagnostic /Imaging" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\5" /v "/Url" /d "https:\\pacs.prpimaging.com.au" /f > $null

    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\6" /v "/Default /Organization" /d "/St /Vincent's /Clinic /Medical /Imaging & /Nuclear /Medicine" /f > $null
    reg add "HKCU\Software\JavaSoft\Prefs\/Intelerad /Medical /Systems\/Clinical /Viewer\/System\/Launcher\/Bookmarks\6" /v "/Url" /d "https:\\pacs.svcmi.com.au" /f > $null

    reg add "HKCU\Software\SVHA\Switches" /v "InteleviewerSVMHSCustomisationsInstalled" /d "1" /f > $null

}