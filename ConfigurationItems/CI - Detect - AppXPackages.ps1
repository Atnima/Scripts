#requires -version 2
<#
.SYNOPSIS
 
  Script to detect unwanted AppX packages in Windows 10

.DESCRIPTION
 
  This script is designed to be added to a ConfigMgr CI to
  detect any unwanted AppX packages from the active user.
  The script will then pass a $true or $false value to
  ConfigMgr.

.INPUTS
  
  None

.OUTPUTS
  
  The script will return a $True or $False value dependant on
  whether there are any present apps. A $False value indicates
  none of the listed apps are present. A $True value indicates
  the inverse.

.NOTES
  Version:        1.0
  Author:         Adam Stevens
  Creation Date:  10/11/2017
  Purpose/Change: Initial script development
  
.EXAMPLE
  
  N/A

#>


$AppName = $null

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

$Exist = Get-AppXPackage | Where-Object Name -in $AppName

If ($Exist) {
    Return $True
}
Else {
    Return $False
}