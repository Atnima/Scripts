
#requires -version 2
<#
.SYNOPSIS
 
  Script to remove unwanted AppX packages in Windows 10

.DESCRIPTION
 
  This script is designed to be added to a ConfigMgr CI to,
  in concert with the associated detection script, remove 
  any unwanted AppX packages from the active user. While it
  is possible to remove AppX packages from the WIM or to remove
  them during OSD, this acts as an assurance measure against
  apps appearing due to updates or via MSFT deployment.

.INPUTS
  
  None

.OUTPUTS
  
  None

.NOTES
  Version:        1.0
  Author:         Adam Stevens
  Creation Date:  10/11/2017
  Purpose/Change: Initial script development
  
.EXAMPLE
  
  N/A
  
#>

$AppName = @(
    "Microsoft.OneConnect"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.3DBuilder"
    "Microsoft.Getstarted"
    "Microsoft.Office.OneNote"
    "Microsoft.BingWeather"
    "Microsoft.Messaging"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.People"
    "Microsoft.windowscommunicationsapps"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsPhone"
    "Microsoft.XboxApp"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.SkypeApp"
)

ForEach ($app in $appname) {
    Write-Verbose "Removing $app"
    Try {
        Get-AppxPackage -Name $app | Remove-AppxPackage -ErrorAction SilentlyContinue
        Write-Verbose "Removing $App Succeeded."
    }

    Catch {
        Write-Verbose "Removing $App Failed."
    }
}