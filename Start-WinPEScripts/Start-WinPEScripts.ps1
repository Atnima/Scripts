#requires -version 2
<#
.SYNOPSIS
  <Overview of script>

.DESCRIPTION
  <Brief description of script>

.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>

.NOTES
  Version:        1.0
  Author:         Adam Stevens
  Creation Date:  03 May 2018
  Purpose/Change: Initial script development
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
#$ErrorActionPreference = "SilentlyContinue"

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function TimedPrompt($prompt,$secondsToWait) {   
    Write-Host -NoNewline $prompt -ForegroundColor Yellow
    $secondsCounter = 0
    $subCounter = 0
    While ( (!$host.ui.rawui.KeyAvailable) -and ($count -lt $secondsToWait) ){
        start-sleep -m 10
        $subCounter = $subCounter + 10
        if($subCounter -eq 1000)
        {
            $secondsCounter++
            $subCounter = 0
            Write-Host -NoNewline "."
        }       
        If ($secondsCounter -eq $secondsToWait) { 
            #Write-Host "`r`n"
            #Write-Host
            return $false;
        }
    }
    #Write-Host "`r`n"
    #Write-Host
    return $true;
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

$OSRootLocation = (Get-WmiObject Win32_OperatingSystem).SystemDirectory
if ($OSRootLocation -like "X:\*") {
    $IsWinPE = $True
}
else {
    $IsWinPE = $False
}
pause
#Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
#Script Execution goes here
#Log-Finish -LogPath $sLogFile

# Hide ProgressUI to prevent it showing on top
if ($IsWinPE) {
    #$TSProgressUI = new-object -comobject Microsoft.SMS.TSProgressUI
    #$TSProgressUI.CloseProgressDialog()
    Clear-Host
}
else {
    Clear-Host
    Write-Host "TEST MODE - Skipping COMObject Creation." -ForegroundColor Yellow
}

## INTRO BANNER AND INFORMATION ##
# Write Random Banner in Window
$BannerOptions = Get-ChildItem .\banners\MainBanner*
$ChosenBanner = Get-Random -InputObject $BannerOptions
Write-Host
$ChosenBannerContents = Get-Content $ChosenBanner
ForEach ($Line in $ChosenBannerContents) {
    Write-Host $Line -ForegroundColor Gray
}
Write-Host
Write-Host
Write-Host "Name:           WinPE Build Script"
Write-Host "Publisher:      St Vincent's Health Australia"
Write-Host "Version:        0.1.0"
Write-Host "Date:           10/05/2018"
Write-Host "Working Dir:   "$(Get-location).Path

if ($IsWinPE) {
    $tsvarobj = New-Object -COMObject Microsoft.SMS.TSEnvironment
}
else {
    Write-Host "TEST MODE - Skipping COMObject Creation." -ForegroundColor Yellow
}

Write-Host
if ($IsWinPE) {
    Start-Sleep -Seconds 5
}
else {

}


## Computer information ##
Write-Host "Device Details"
$ComputerSystem = Get-WmiObject Win32_ComputerSystem
Write-Host "Name:          "$ComputerSystem.Name
if ($ComputerSystem.Manufacturer -like "HP") {
    Write-Host "Vendor:         Hewlett-Packard"
} 
else {
    Write-Host "Vendor:        "$ComputerSystem.Manufacturer
}
Write-Host "Model:         "$ComputerSystem.Model
Write-Host "OS Type:        " -NoNewline


if ($IsWinPE) {
    Write-Host "Windows Preinstallation Environment (WinPE)" -ForegroundColor Green
}
else {
    Write-Host "Windows - Test Mode Active" -ForegroundColor Yellow
}

$IPAddress = (Get-WmiObject Win32_NetworkAdapterConfiguration).IPAddress | Where-Object {$_ -match "([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})"}
Write-Host "IP Address:     $IPAddress"

If ($ComputerSystem.Manufacturer -like "Lenovo") {

}
Else {
    $BIOSTag = Get-WmiObject Win32_SystemEnclosure
    Write-Host "BIOS Asset Tag:" -NoNewline

    if ($BIOSTag.SMBIOSAssetTag -match "^\d{6}$") {
        Write-Host ""$BiosTag.SMBIOSAssetTag 
    }
    else {
        Write-Host ""$BiosTag.SMBIOSAssetTag 
    }
}
Write-Host

## Checking BIOS asset tag ##
Write-Host "Checking device name in BIOS..."
Write-Host "BIOS Asset Tag Present: " -NoNewline
if ($BIOSTag.SMBiosAssetTag -match "\w|\d") {
    Write-Host True -ForegroundColor Green
}
else {
    Write-Host "False" -ForegroundColor Red
}
Write-Host "Asset Tag Meets Standard: " -NoNewline
if ($BIOSTag.SMBIOSAssetTag -match "^\d{6}$") {
    Write-Host "True" -ForegroundColor Green
    $AssetTagStandard = $true
}
else {
    Write-Host "False" -ForegroundColor Red
    $AssetTagStandard = $false
}
Write-Host "BIOS Manufacturer Tool Available: " -NoNewline
if ($ComputerSystem.Manufacturer -eq "Microsoft Corporation") {
    Write-Host "True" -ForegroundColor Green
    $AssetTagToolAvailable = $true
}
else {
    Write-Host "False" -ForegroundColor Red
    $AssetTagToolAvailable = $false
}

if ($BIOSTag.SMBIOSAssetTag -notmatch "^\d{6}$") {
    Write-Warning "Asset tag can not be set in the BIOS automatically. Please enter the asset tag in the BIOS manually."
}

## Writing BIOS Asset Tag where possible. ##
if ($AssetTagToolAvailable -eq $true -and $AssetTagStandard -eq $false) {
    Write-Host
    Write-Host "Attempting to write asset tag to BIOS..."
    if ($ComputerSystem.Manufacturer -eq "Microsoft Corporation") {
        $ValidTagEntered = $false
        $ValidTagEasterEgg = 0
        do {
            if ($ValidTagEasterEgg -eq 2) {
                Write-Host "Did you know... 1 centillion is 1 followed by 303 zeros." -ForegroundColor Yellow
            }
            if ($ValidTagEasterEgg -eq 3) {
                Write-Host "The bloodhound is the only animal whose evidence is admissible in court." -ForegroundColor Yellow
            }
            if ($ValidTagEasterEgg -eq 4) {
                Write-Host "The chance of you dying on the way to get lottery tickets is actually greater than your chance of winning." -ForegroundColor Yellow
            } 
            $ReadAssetFromUser = Read-Host "Please enter the 6 digit asset number"
            if ($ReadAssetFromUser -match "^\d{6}$") {
                $ValidTagEntered = $True
            }
            else {
                Write-Host "Invalid asset tag entered..." -ForegroundColor Red
                Write-Host
                $ValidTagEasterEgg++
            }
        }
        While ($ValidTagEntered -eq $false)

        #Write asset tag
        Write-Host "Now attempting to write asset tag to hardware."
        if ($IsWinPE) {
            .\resources\microsoft-assettagutility\AssetTag.exe -s "$ReadAssetFromUser"
        }
        else {
            Write-Host "TEST MODE - Skipping Asset Tag set." -ForegroundColor Yellow
        }

        Write-Host
        Write-Host "The device will now be shut down in 10 seconds to apply the asset tag. Please boot back into WinPE to continue." -NoNewline
        $ScrollingDots = 0
        do {
            Start-Sleep -Seconds 2
            Write-Host "." -NoNewline
            $ScrollingDots++
        }
        While ($ScrollingDots -lt "5")
        Write-Host

        if ($IsWinPE) {
            wpeutil shutdown
        }
        else {
            Write-Host "TEST MODE - Skipping WinPE shutdown command" -ForegroundColor Yellow
        }
    }
    elseif ($ComputerSystem.Manufacturer -eq "HP") {
        ## (Get-Content C:\temp\config.txt ).Replace("#ENTERASSETTAG#","$AssetTag") | Out-File C:\temp\output.txt
    }
}
else {
    Write-Host "Asset tag is correct. Continuing." -ForegroundColor Green
}

Write-Host

## Checking if device is located at Data#3
$WMIChassisType = (Get-WmiObject Win32_SystemEnclosure).ChassisTypes
Write-Host "Automated Build Check..."
Write-Host "Data#3 IP Range:    172.19.8.0/24"
Write-Host "Regex Expression:   ^(172)\.(19)\.(65)\.([0-9]{1,3})$"
Write-Host "Chassis Type:       $WMIChassisType"
if ($IPAddress -match "^(172)\.(19)\.(65)\.([0-9]{1,3})$" -or $IPAddress -eq "172.19.5.3") {
    $WMIAssetTag = (Get-WmiObject Win32_SystemEnclosure).SMBIOSAssetTag
    Write-Host "BIOS Asset Tag:     " -NoNewline
    if ($WMIAssetTag -match "^([0-9]{6})$") {
        # BIOS HAS BEEN SET RIGHT
        Write-Host "OK ($WMIAssetTag)" -ForegroundColor Green
        $BIOSTagCorrect = $true
    }
    else {
        Write-Host "FAIL ($WMIAssetTag)" -ForegroundColor Red
        $BIOSTagCorrect = $false
    }

    # Check and determine name
    if ($BIOSTagCorrect) {
        #TAG IS RIGHT
        switch ( $WMIChassisType ) 
        {
            #Notebook
            9 { $BarcodePrefix = "N" }
            10 { $BarcodePrefix = "N" }
            14 { $BarcodePrefix = "N" }
            31 { $BarcodePrefix = "N" }
            #Desktop
            3 { $BarcodePrefix = "D" }
            6 { $BarcodePrefix = "D" }
            15 { $BarcodePrefix = "D" }
            35 { $BarcodePrefix = "D" }
            #Unknown
            default { $NameGenFailed = $true }
        }
        if ($NameGenFailed) {
            Write-Warning "Name generation failed due to unknown Chassis Type ($WMIChassisType)"
            Write-Warning "Please report this to a system administrator."
            $ValidPrefixEntered = $false
            do {
                $ReadAssetFromUser = Read-Host "Please enter prefix (D/N)"
                if ($ReadAssetFromUser -ceq "D" -or $ReadAssetFromUser -ceq "N") {
                    $ValidPrefixEntered = $True
                }
                else {
                    Write-Host "Please only enter D or N (capitalised)." -ForegroundColor Red
                    Write-Host
                }
            }
            While ($ValidPrefixEntered -eq $false)
        }
        else {
            Write-Host "Hardware Type:      " -NoNewline
            if ($BarcodePrefix -ceq "D") {
                Write-Host "Desktop" -ForegroundColor Green
            }
            elseif ($BarcodePrefix -ceq "N") {
                Write-Host "Laptop" -ForegroundColor Green
            }
        }

        <#Notebook
        if ('9','10','14','31' -contains $WMIChassisType) {
            $tsvarobj.Value("SVHAAssetTag") = "N$WMIAssetTag"
            if ($tsvarobj.Value("SVHAAssetTag") -eq "N$WMIAssetTag") {
                Write-Host "Notebook Asset Tag: OK" -ForegroundColor Green
            }
            else {
                Write-Host "Notebook Asset Tag: FAIL" -ForegroundColor Red
            }           
        }
        #Desktop
        elseif ('3','6','15','35' -contains $WMIChassisType) {
            $tsvarobj.Value("SVHAAssetTag") = "D$WMIAssetTag"
            if ($tsvarobj.Value("SVHAAssetTag") -eq "D$WMIAssetTag") {
                Write-Host "Desktop Asset Tag: OK" -ForegroundColor Green
            }
            else {
                Write-Host "Desktop Asset Tag: FAIL" -ForegroundColor Red
            }  
        }#>

        Write-Host "Generated Tag:      " -NoNewline
        $FullyGeneratedAssetTag = "$BarcodePrefix$WMIAssetTag"
        Write-Host $FullyGeneratedAssetTag -ForegroundColor Green
        Write-Host
        Write-Host "Device Name Variable: " -NoNewline
        if ($IsWinPE) {
            $FullyGeneratedAssetTag = $tsvarobj.Value("SVHAAssetTag")
            Write-Host "OK" -ForegroundColor Green
        }
        else {
            Write-Host "SKIPPED (Test Mode)" -ForegroundColor Yellow
        }
        
    }
    else {

        Write-Host "FAIL" -ForegroundColor Red
        Write-Host
        Write-Warning "Unable to continue, asset tag is incorrect in BIOS."
        Write-Warning "Task Sequence will now fail."
        Pause
        Exit 1
    }
    
    # Ask if timezone needs to change
    $TimezoneNotDefault = TimedPrompt "AEDT Timezone is the default. Press any key for AEST." 10
    Write-Host
    if ($TimezoneNotDefault) {
        $tsvarobj.Value("SVHALocation") = "BRIS"
        if ($tsvarobj.Value("SVHALocation") -eq "BRIS") {
            Write-Host "Timezone AEST: OK" -ForegroundColor Green
        }
        else {
            Write-Host "Timezone AEST: FAIL" -ForegroundColor Red
        }
    }
    else {
        $tsvarobj.Value("SVHALocation") = "MEL"
        if ($tsvarobj.Value("SVHALocation") -eq "MEL") {
            Write-Host "Timezone AEDT: OK" -ForegroundColor Green
        }
        else {
            Write-Host "Timezone AEDT: FAIL" -ForegroundColor Red
        }
    }

    #Set SVHAWindowsVersion variable
    Write-Host "Windows 10 Variable: " -NoNewline
    if ($IsWinPE) {
        $tsvarobj.Value("SVHAWindowsVersion") = "10"
        if ($tsvarobj.Value("SVHAWindowsVersion") -eq "10") {
            Write-Host "OK" -ForegroundColor Green
        }
        else {
            Write-Host "FAIL" -ForegroundColor Red
        }
    }
    else {
        Write-Host "SKIPPED (Test Mode)" -ForegroundColor Yellow
    }

    #Set CustomWindowsVersion variable
    Write-Host "WinVer Variable: " -NoNewline
    if ($IsWinPE) {
        $tsvarobj.Value("CustomWindowsVersion") = "1709"
        if ($tsvarobj.Value("CustomWindowsVersion") -eq "1709") {
        Write-Host "OK" -ForegroundColor Green
        }
        else {
        Write-Host "FAIL" -ForegroundColor Red
        }
    }
    else {
        Write-Host "SKIPPED (Test Mode)" -ForegroundColor Yellow
    }

    #Set SVHAOffice variable
    Write-Host "Office Variable: " -NoNewline
    if ($IsWinPE) {
        $tsvarobj.Value("SVHAOffice") = "VLK86"
        if ($tsvarobj.Value("SVHAOffice") -eq "VLK86") {
            Write-Host "OK" -ForegroundColor Green
        }
        else {
            Write-Host "FAIL" -ForegroundColor Red
        }
    }
    else {
        Write-Host "SKIPPED (Test Mode)" -ForegroundColor Yellow
    }

    #Write TSVariable to notify TS that options are set
    Write-Host "AutoBuild Variable: " -NoNewline
    if ($IsWinPE) {
        $tsvarobj.Value("SVHAData3Options") = "True"
        if ($tsvarobj.Value("SVHAData3Options") -eq "True") {
            Write-Host "OK" -ForegroundColor Green
        }
        else {
            Write-Host "FAIL" -ForegroundColor Red
        }
    }
    else {
        Write-Host "SKIPPED (Test Mode)" -ForegroundColor Yellow
    }

    Write-Host "Setting Variables Complete." -ForegroundColor Green
    Start-Sleep 5
}
else {
    Write-Host "Computer is not located at Data#3" -ForegroundColor Green
}

Write-Host

if ($IsWinPE) {
    Write-Host "Setting SMSTSPreferredAdvertID"

    $tsvarobj = New-Object -COMObject Microsoft.SMS.TSEnvironment
    $tsvarobj.Value("SMSTSPreferredAdvertID") = "SVH200AC"
    Write-Host
}
else {
    Write-Host "TEST MODE - Skipping SMSTSPreferredAdvertID" -ForegroundColor Yellow
}

Start-Sleep 5
Pause
Write-Host