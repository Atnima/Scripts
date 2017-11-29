Dim objShell
Set objShell=CreateObject("WScript.Shell")
strCMD="powershell -sta -noProfile -NonInteractive -executionpolicy bypass -nologo -file ""C:\Program Files\SVHA\Write-SVHTInteleviewerEntries.ps1""" 
objShell.Run strCMD,0