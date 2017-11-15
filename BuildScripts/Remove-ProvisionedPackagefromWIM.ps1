#requires -version 2
<#
.SYNOPSIS
 
  Script to remove unwanted AppX packages in Windows 10 mounted WIM

.DESCRIPTION
 
  This script is designed to be used against a mounted WIM image
  to remove AppX Provisioned Packages from the image itself, preventing
  them from being installed during OSD.

.INPUTS
  
  None

.OUTPUTS
  
  None

.NOTES
  Version:        1.0
  Author:         Adam Stevens
  Creation Date:  15/11/2017
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

$mountpath = Read-Host "Please provide the path to the mounted wim"

ForEach ($app in $appname) {
    # Nulling the variable as I dont know how it works in PS
    $DoesAppExist = $null

    # Checking app exists before attempting to remove
 
        Write-Verbose "Checking if app is present in image."
        $DoesAppExist = Get-AppxProvisionedPackage -Path $mountpath | Where-Object DisplayName -eq "$app"
        
        If ($DoesAppExist) {
            Write-Host "$app Found" -ForegroundColor Green
            Write-Verbose "Removing $app Provisioned Package."

            Try {
                Get-AppxProvisionedPackage -Path $mountpath | Where-Object DisplayName -eq "$app" | Remove-AppxProvisionedPackage -Path $mountpath -ErrorAction SilentlyContinue
                Write-Host "Removing $App Provisioned Package Succeeded." -ForegroundColor Green
            }
            Catch {
                Write-Verbose "Removing $App Provisioned Package Failed."
            }
        }

        Else{
            Write-Host "$app Not Found" -ForegroundColor Yellow
        }
    

}