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

param (
    [switch][bool]$Data3,
    [switch][bool]$Drivers,
    [switch][bool]$Apps,
    [switch][bool]$SurfaceAssetTag,
    [switch][bool]$testSwitch
);

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#Dot Source required Function Libraries
. ".\functions\Logging_Functions.ps1"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Switches


#Script Name
$ScriptName = "WinPE-PS-Script"

#Script Version
$sScriptVersion = "1.0"

#Log File Info
$sLogPath = "C:\Windows\Temp"
$sLogName = "OSD-PS-Script.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#-----------------------------------------------------------[Functions]------------------------------------------------------------

<#

Function <FunctionName>{
  Param()
  
  Begin{
    Log-Write -LogPath $sLogFile -LineValue "<description of what is going on>..."
  }
  
  Process{
    Try{
      <code goes here>
    }
    
    Catch{
      Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
      Break
    }
  }
  
  End{
    If($?){
      Log-Write -LogPath $sLogFile -LineValue "Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
    }
  }
}

#>

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

Function Write-CMTraceLog{
 
	########################################################################################################## 
	<# 
	.SYNOPSIS 
	   Write to a log file in a format that takes advantage of the CMTrace.exe log viewer that comes with SCCM.
	 
	.DESCRIPTION 
	   Output strings to a log file that is formatted for use with CMTRace.exe and also writes back to the host.
	 
	   The severity of the logged line can be set as: 
	 
			2-Error
			3-Warning
			4-Verbose
			5-Debug
			6-Information
	 
	 
	   Warnings will be highlighted in yellow. Errors are highlighted in red. 
	 
	   The tools to view the log: 
	 
	   SMS Trace - http://www.microsoft.com/en-us/download/details.aspx?id=18153 
	   CM Trace - https://www.microsoft.com/en-us/download/details.aspx?id=50012 or the Installation directory on Configuration Manager 2012 Site Server - <Install Directory>\tools\ 
	 
	.EXAMPLE 
	Try{
		Get-Process -Name DoesnotExist -ea stop
	}
	Catch{
		Write-CMTraceLog -Logfile "C:\output\logfile.log -Message $Error[0] -Type Error
	}
	 
	   This will write a line to the logfile.log file in c:\output\logfile.log. It will state the errordetails in the log file 
	   and highlight the line in Red. It will also write back to the host in a friendlier red on black message than
	   the normal error record.
	 
	.EXAMPLE
	 $VerbosePreference = Continue
	 Write-CMTraceLog -Message "This is a verbose message." -Type Verbose
	 
	   This example will write a verbose entry into the log file and also write back to the host. The Write-CMTraceLog will obey
	   the preference variables.
	 
	.EXAMPLE
	Write-CMTraceLog -Message "This is an informational message" -Type Information -WritebacktoHost:$false
	 
		This example will write the informational message to the log but not back to the host.
	 
	.EXAMPLE
	Function Test{
		[cmdletbinding()]
		Param()
		Write-CMTraceLog -Message "This is a verbose message" -Type Verbose
	}
	Test -Verbose
	 
	This example shows how to use write-cmtracelog inside a function and then call the function with the -verbose switch.
	The write-cmtracelog function will then print the verbose message.
	 
	.NOTES
		
		##########
		Change Log
		##########
		
		v1.5 - 12-03-2015 - Found bug with Error writing back to host twice. Fixed.
	 
		##########
		
		v1.4 - 12-03-2015 - Found bug with Warning writebackto host duplicating warning error message.
							Fixed.
	 
		##########
		
		v1.3 - 23-12-2015 - Commented out line 224 and 249 as it was causing a duplicaton of the message.
	 
		##########
	 
		v1.2 - Fixed inheritance of preference variables from child scopes finally!! Changed from using
				using get-variable -scope 1 (which doesn't work when a script modules calls a function:
				See this Microsoft Connect bug https://connect.microsoft.com/PowerShell/feedback/details/1606119.)
				Anyway now now i use the $PSCmdlet.GetVariableValue('VerbosePreference') command and it works.
		
		##########
	 
		v1.1 - Found a bug with the get-variable scope. Need to refer to 2 parent scopes for the writebacktohost to work.
			 - Changed all Get-Variable commands to use Scope 2, instead of Scope 1.
	 
		##########
	 
		v1.0 - Script Created
	#> 
	########################################################################################################## 
	 
		#Define and validate parameters 
		[CmdletBinding()] 
		Param( 
	 
			#Path to the log file 
			[parameter(Mandatory=$False)]      
			[String]$Logfile = "$Env:Temp\powershell-cmtrace.log",
			 
			#The information to log 
			[parameter(Mandatory=$True)] 
			$Message,
	 
			#The severity (Error, Warning, Verbose, Debug, Information)
			[parameter(Mandatory=$True)]
			[ValidateSet('Warning','Error','Verbose','Debug', 'Information')] 
			[String]$Type,
	 
			#Write back to the console or just to the log file. By default it will write back to the host.
			[parameter(Mandatory=$False)]
			[switch]$WriteBackToHost = $False
	 
		)#Param
	 
		#Get the info about the calling script, function etc
		$callinginfo = (Get-PSCallStack)[1]
	 
		#Set Source Information
		$Source = (Get-PSCallStack)[1].Location
	 
		#Set Component Information
		$Component = (Get-Process -Id $PID).ProcessName
	 
		#Set PID Information
		$ProcessID = $PID
	 
		#Obtain UTC offset 
		$DateTime = New-Object -ComObject WbemScripting.SWbemDateTime  
		$DateTime.SetVarDate($(Get-Date)) 
		$UtcValue = $DateTime.Value 
		$UtcOffset = $UtcValue.Substring(21, $UtcValue.Length - 21)
	 
		#Set the order 
		switch($Type){
			   'Warning' {$Severity = 2}#Warning
				 'Error' {$Severity = 3}#Error
			   'Verbose' {$Severity = 4}#Verbose
				 'Debug' {$Severity = 5}#Debug
		   'Information' {$Severity = 6}#Information
		}#Switch
	 
		#Switch statement to write out to the log and/or back to the host.
		switch ($severity){
			2{
				#Warning
				
				#Write the log entry in the CMTrace Format.
				 $logline = `
				"<![LOG[$($($Type.ToUpper()) + ": " +  $message)]LOG]!>" +`
				"<time=`"$(Get-Date -Format HH:mm:ss.fff)$($UtcOffset)`" " +`
				"date=`"$(Get-Date -Format M-d-yyyy)`" " +`
				"component=`"$Component`" " +`
				"context=`"$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`" " +`
				"type=`"$Severity`" " +`
				"thread=`"$ProcessID`" " +`
				"file=`"$Source`">";
				$logline | Out-File -Append -Encoding utf8 -FilePath $Logfile;
				
				#Write back to the host if $Writebacktohost is true.
				if(($WriteBackToHost) -and ($Type -eq 'Warning')){
					Switch($PSCmdlet.GetVariableValue('WarningPreference')){
						'Continue' {$WarningPreference = 'Continue';Write-Warning -Message "$Message";$WarningPreference=''}
						'Stop' {$WarningPreference = 'Stop';Write-Warning -Message "$Message";$WarningPreference=''}
						'Inquire' {$WarningPreference ='Inquire';Write-Warning -Message "$Message";$WarningPreference=''}
						'SilentlyContinue' {}
					}
				}
			}#Warning
			3{  
				#Error
	 
				#This if statement is to catch the two different types of errors that may come through. A normal terminating exception will have all the information that is needed, if it's a user generated error by using Write-Error,
				#then the else statment will setup all the information we would like to log.   
				if($Message.exception.Message){                
					if(($WriteBackToHost)-and($Type -eq 'Error')){                                        
						#Write the log entry in the CMTrace Format.
						$logline = `
						"<![LOG[$($($Type.ToUpper()) + ": " +  "$([String]$Message.exception.message)`r`r" + `
						"`nCommand: $($Message.InvocationInfo.MyCommand)" + `
						"`nScriptName: $($Message.InvocationInfo.Scriptname)" + `
						"`nLine Number: $($Message.InvocationInfo.ScriptLineNumber)" + `
						"`nColumn Number: $($Message.InvocationInfo.OffsetInLine)" + `
						"`nLine: $($Message.InvocationInfo.Line)")]LOG]!>" +`
						"<time=`"$(Get-Date -Format HH:mm:ss.fff)$($UtcOffset)`" " +`
						"date=`"$(Get-Date -Format M-d-yyyy)`" " +`
						"component=`"$Component`" " +`
						"context=`"$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`" " +`
						"type=`"$Severity`" " +`
						"thread=`"$ProcessID`" " +`
						"file=`"$Source`">"
						$logline | Out-File -Append -Encoding utf8 -FilePath $Logfile;
						#Write back to Host
						Switch($PSCmdlet.GetVariableValue('ErrorActionPreference')){
							'Stop'{$ErrorActionPreference = 'Stop';$Host.Ui.WriteErrorLine("ERROR: $([String]$Message.Exception.Message)");Write-Error $Message -ErrorAction 'Stop';$ErrorActionPreference=''}
							'Inquire'{$ErrorActionPreference = 'Inquire';$Host.Ui.WriteErrorLine("ERROR: $([String]$Message.Exception.Message)");Write-Error $Message -ErrorAction 'Inquire';$ErrorActionPreference=''}
							'Continue'{$ErrorActionPreference = 'Continue';$Host.Ui.WriteErrorLine("ERROR: $([String]$Message.Exception.Message)");$ErrorActionPreference=''}
							'Suspend'{$ErrorActionPreference = 'Suspend';$Host.Ui.WriteErrorLine("ERROR: $([String]$Message.Exception.Message)");Write-Error $Message -ErrorAction 'Suspend';$ErrorActionPreference=''}
							'SilentlyContinue'{}
						}
	 
					}
					else{                   
						#Write the log entry in the CMTrace Format.
						$logline = `
						"<![LOG[$($($Type.ToUpper()) + ": " +  "$([String]$Message.exception.message)`r`r" + `
						"`nCommand: $($Message.InvocationInfo.MyCommand)" + `
						"`nScriptName: $($Message.InvocationInfo.Scriptname)" + `
						"`nLine Number: $($Message.InvocationInfo.ScriptLineNumber)" + `
						"`nColumn Number: $($Message.InvocationInfo.OffsetInLine)" + `
						"`nLine: $($Message.InvocationInfo.Line)")]LOG]!>" +`
						"<time=`"$(Get-Date -Format HH:mm:ss.fff)$($UtcOffset)`" " +`
						"date=`"$(Get-Date -Format M-d-yyyy)`" " +`
						"component=`"$Component`" " +`
						"context=`"$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`" " +`
						"type=`"$Severity`" " +`
						"thread=`"$ProcessID`" " +`
						"file=`"$Source`">"
						$logline | Out-File -Append -Encoding utf8 -FilePath $Logfile;
					}
				}
				else{
					if(($WriteBackToHost)-and($type -eq 'Error')){
						[System.Exception]$Exception = $Message
						[String]$ErrorID = 'Custom Error'
						[System.Management.Automation.ErrorCategory]$ErrorCategory = [Management.Automation.ErrorCategory]::WriteError
						#[System.Object]$Message
						$ErrorRecord = New-Object Management.automation.errorrecord ($Exception,$ErrorID,$ErrorCategory,$Message)
						$Message = $ErrorRecord
						#Write the log entry
						$logline = `
							"<![LOG[$($($Type.ToUpper()) + ": " +  "$([String]$Message.exception.message)`r`r" + `
							"`nFunction: $($Callinginfo.FunctionName)" + `
							"`nScriptName: $($Callinginfo.Scriptname)" + `
							"`nLine Number: $($Callinginfo.ScriptLineNumber)" + `
							"`nColumn Number: $($callinginfo.Position.StartColumnNumber)" + `
							"`nLine: $($Callinginfo.Position.StartScriptPosition.Line)")]LOG]!>" +`
							"<time=`"$(Get-Date -Format HH:mm:ss.fff)$($UtcOffset)`" " +`
							"date=`"$(Get-Date -Format M-d-yyyy)`" " +`
							"component=`"$Component`" " +`
							"context=`"$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`" " +`
							"type=`"$Severity`" " +`
							"thread=`"$ProcessID`" " +`
							"file=`"$Source`">"
							$logline | Out-File -Append -Encoding utf8 -FilePath $Logfile;
						#Write back to Host.
						Switch($PSCmdlet.GetVariableValue('ErrorActionPreference')){
								'Stop'{$ErrorActionPreference = 'Stop';$Host.Ui.WriteErrorLine("ERROR: $([String]$Message.Exception.Message)");Write-Error $Message -ErrorAction 'Stop';$ErrorActionPreference=''}
								'Inquire'{$ErrorActionPreference = 'Inquire';$Host.Ui.WriteErrorLine("ERROR: $([String]$Message.Exception.Message)");Write-Error $Message -ErrorAction 'Inquire';$ErrorActionPreference=''}
								'Continue'{$ErrorActionPreference = 'Continue';$Host.Ui.WriteErrorLine("ERROR: $([String]$Message.Exception.Message)");Write-Error $Message 2>&1 > $null;$ErrorActionPreference=''}
								'Suspend'{$ErrorActionPreference = 'Suspend';$Host.Ui.WriteErrorLine("ERROR: $([String]$Message.Exception.Message)");Write-Error $Message -ErrorAction 'Suspend';$ErrorActionPreference=''}
								'SilentlyContinue'{}
							}
					}
					else{
						#Write the Log Entry
						[System.Exception]$Exception = $Message
						[String]$ErrorID = 'Custom Error'
						[System.Management.Automation.ErrorCategory]$ErrorCategory = [Management.Automation.ErrorCategory]::WriteError
						#[System.Object]$Message
						$ErrorRecord = New-Object Management.automation.errorrecord ($Exception,$ErrorID,$ErrorCategory,$Message)
						$Message = $ErrorRecord
						#Write the log entry
						$logline = `
							"<![LOG[$($($Type.ToUpper())+ ": " +  "$([String]$Message.exception.message)`r`r" + `
							"`nFunction: $($Callinginfo.FunctionName)" + `
							"`nScriptName: $($Callinginfo.Scriptname)" + `
							"`nLine Number: $($Callinginfo.ScriptLineNumber)" + `
							"`nColumn Number: $($Callinginfo.Position.StartColumnNumber)" + `
							"`nLine: $($Callinginfo.Position.StartScriptPosition.Line)")]LOG]!>" +`
							"<time=`"$(Get-Date -Format HH:mm:ss.fff)$($UtcOffset)`" " +`
							"date=`"$(Get-Date -Format M-d-yyyy)`" " +`
							"component=`"$Component`" " +`
							"context=`"$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`" " +`
							"type=`"$Severity`" " +`
							"thread=`"$ProcessID`" " +`
							"file=`"$Source`">"
							$logline | Out-File -Append -Encoding utf8 -FilePath $Logfile;
					}                
				}   
			}#Error
			4{  
				#Verbose
				
				#Write the Log Entry
				
				$logline = `
				"<![LOG[$($($Type.ToUpper()) + ": " +  $message)]LOG]!>" +`
				"<time=`"$(Get-Date -Format HH:mm:ss.fff)$($UtcOffset)`" " +`
				"date=`"$(Get-Date -Format M-d-yyyy)`" " +`
				"component=`"$Component`" " +`
				"context=`"$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`" " +`
				"type=`"$severity`" " +`
				"thread=`"$processid`" " +`
				"file=`"$source`">";
				$logline | Out-File -Append -Encoding utf8 -FilePath $Logfile; 
				
				#Write Back to Host
					
				if(($WriteBackToHost) -and ($Type -eq 'Verbose')){
					Switch ($PSCmdlet.GetVariableValue('VerbosePreference')) {
						'Continue' {$VerbosePreference = 'Continue'; Write-Verbose -Message "$Message";$VerbosePreference = ''}
						'Inquire' {$VerbosePreference = 'Inquire'; Write-Verbose -Message "$Message";$VerbosePreference = ''}
						'Stop' {$VerbosePreference = 'Stop'; Write-Verbose -Message "$Message";$VerbosePreference = ''}
					}
				}              
		   
			}#Verbose
			5{  
				#Debug
	 
				#Write the Log Entry
				
				$logline = `
				"<![LOG[$($($Type.ToUpper()) + ": " +  $message)]LOG]!>" +`
				"<time=`"$(Get-Date -Format HH:mm:ss.fff)$($UtcOffset)`" " +`
				"date=`"$(Get-Date -Format M-d-yyyy)`" " +`
				"component=`"$Component`" " +`
				"context=`"$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`" " +`
				"type=`"$severity`" " +`
				"thread=`"$processid`" " +`
				"file=`"$source`">";
				$logline | Out-File -Append -Encoding utf8 -FilePath $Logfile;  
	 
				#Write Back to the Host.                              
	 
				if(($WriteBackToHost) -and ($Type -eq 'Debug')){
					Switch ($PSCmdlet.GetVariableValue('DebugPreference')){
						'Continue' {$DebugPreference = 'Continue'; Write-Debug -Message "$Message";$DebugPreference = ''}
						'Inquire' {$DebugPreference = 'Inquire'; Write-Debug -Message "$Message";$DebugPreference = ''}
						'Stop' {$DebugPreference = 'Stop'; Write-Debug -Message "$Message";$DebugPreference = ''}
					}
				} 
						  
			}#Debug
			6{  
				#Information
	 
				#Write entry to the logfile.
	 
				$logline = `
				"<![LOG[$($($Type.ToUpper()) + ": " + $message)]LOG]!>" +`
				"<time=`"$(Get-Date -Format HH:mm:ss.fff)$($UtcOffset)`" " +`
				"date=`"$(Get-Date -Format M-d-yyyy)`" " +`
				"component=`"$Component`" " +`
				"context=`"$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`" " +`
				"type=`"$severity`" " +`
				"thread=`"$processid`" " +`
				"file=`"$source`">";            
				$logline | Out-File -Append -Encoding utf8 -FilePath $Logfile;
	 
				#Write back to the host.
	 
				if(($WriteBackToHost) -and ($Type -eq 'Information')){
					Switch ($PSCmdlet.GetVariableValue('InformationPreference')){
						'Continue' {$InformationPreference = 'Continue'; Write-Information -Message "INFORMATION: $Message";$InformationPreference = ''}
						'Inquire' {$InformationPreference = 'Inquire'; Write-Information -Message "INFORMATION: $Message";$InformationPreference = ''}
						'Stop' {$InformationPreference = 'Stop'; Write-Information -Message "INFORMATION: $Message";$InformationPreference = ''}
						'Suspend' {$InformationPreference = 'Suspend';Write-Information -Message "INFORMATION: $Message";$InformationPreference = ''}
					}
				}
			}#Information
		}#Switch
}#Function v1.5 - 12-03-2016


#-----------------------------------------------------------[Execution]------------------------------------------------------------


#Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
#Script Execution goes here
#Log-Finish -LogPath $sLogFile

# Hide ProgressUI to prevent it showing on top
if ($IsWinPE) {
    $TSProgressUI = new-object -comobject Microsoft.SMS.TSProgressUI
    $TSProgressUI.CloseProgressDialog()
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

$OSRootLocation = (Get-WmiObject Win32_OperatingSystem).SystemDirectory
if ($OSRootLocation -like "X:\*") {
    Write-Host "Windows Preinstallation Environment (WinPE)" -ForegroundColor Green
    $IsWinPE = $True
}
else {
    Write-Host "Windows - Test Mode Active" -ForegroundColor Yellow
    $IsWinPE = $False
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
    Write-Warning "Asset tag can not be set in the BIOS automatically. Please enter the asset tag in the BIOS manually."
    $AssetTagToolAvailable = $false
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
Write-Host "Data#3 Automated Build Check..."
Write-Host "Data#3 IP Range:    172.19.8.0/24"
Write-Host "Regex Expression:   ^(172)\.(19)\.(65)\.([0-9]{1,3})$"
Write-Host "Chassis Type:       $WMIChassisType"
if ($IPAddress -match "^(172)\.(19)\.(65)\.([0-9]{1,3})$" -or $IPAddress -eq "172.19.5.98") {
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

        if ($BarcodePrefix -ceq "D") {
            Hardware Type Detected
        }
        elseif ($BarcodePrefix -ceq "N") {
            
        }
        else {
            Write-Host "FAIL" -ForegroundColor Red
            start-sleep -seconds 10
            exit 1
        }

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
    exit 0
}
else {
    Write-Host "Computer is not located at Data#3" -ForegroundColor Green
    Start-Sleep 5
}

if ($IsWinPE) {
    Write-Host "Setting SMSTSPreferredAdvertID"

    $tsvarobj = New-Object -COMObject Microsoft.SMS.TSEnvironment
    $tsvarobj.Value("SMSTSPreferredAdvertID") = "SVH200AC"
    Write-Host
    Pause
}
else {
    Write-Host "TEST MODE - Skipping SMSTSPreferredAdvertID" -ForegroundColor Yellow
}

Write-Host