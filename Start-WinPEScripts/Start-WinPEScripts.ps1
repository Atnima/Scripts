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
$ScriptName = "OSD-PS-Script"

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
$TSProgressUI = new-object -comobject Microsoft.SMS.TSProgressUI
$TSProgressUI.CloseProgressDialog()

$tsvarobj = New-Object -COMObject Microsoft.SMS.TSEnvironment

## INTRO BANNER AND INFORMATION ##
# Write Random Banner in Window
Clear-Host
$BannerOptions = Get-ChildItem .\banners\MainBanner*
$ChosenBanner = Get-Random -InputObject $BannerOptions
Write-Host
Get-Content $ChosenBanner
Write-Host
Write-Host

# This section of the script runs the automated Data3 section to prevent UI execution and set required variables.
if ($Data3) {

    # Read WMI Variables
    $IPAddress = (Get-WmiObject Win32_NetworkAdapterConfiguration).IPAddress | Where-Object {$_ -match "([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})"}
    $WMIChassisType = (Get-WmiObject Win32_SystemEnclosure).ChassisTypes

    # Read TS Variables
    #$tsvarobj = New-Object -COMObject Microsoft.SMS.TSEnvironment

    #$HostNameTSVAR = $tsenv.Value("OSDComputerName")
    #Write-Host "Host name:" $HostNameTSVAR

    # Determine PC Name
    $WMIAssetTag = (Get-WmiObject Win32_SystemEnclosure).SMBIOSAssetTag
    if ($WMIAssetTag -match "^([0-9]{6})$") {
        # BIOS HAS BEEN SET RIGHT
        Write-Host "BIOS Asset Tag: OK ($WMIAssetTag)" -ForegroundColor Green
        $BIOSTagCorrect = $true
    }
    else {
        Write-Host "BIOS Asset Tag: FAIL ($WMIAssetTag)" -ForegroundColor Red
        $BIOSTagCorrect = $false
    }

    # BIOS Ownership
    #$DeviceManufacturer = (Get-WmiObject Win32_ComputerSystem).Manufacturer
    #if ($DeviceManufacturer -eq "Hewlett-Packard") {
    #    $DeviceOwnership = (Get-WmiObject -Class HPBIOS_BIOSString -Namespace "ROOT\HP\InstrumentedBIOS" | Where-Object {$_.Name -like "Enter Ownership Tag"}).Value
    #    Write-Host "Device Ownership: OK ($DeviceOwnership)"
    #}

    # Write IP Address for troubleshooting
    Write-Host "IPv4 Address: OK ($IPAddress)" -ForegroundColor Green

    # Run script
    ## -or $IPAddress -match "^(172)\.(19)\.(8)\.([0-9]{1,3})$")
    ## Check if device has a Data 3 or **TEST DESK** IP address.
    if ($IPAddress -match "^(172)\.(19)\.(65)\.([0-9]{1,3})$") {
        # Check and determine name
        if ($BIOSTagCorrect) {
            #TAG IS RIGHT

            #Notebook
            if ('9','10','14' -contains $WMIChassisType) {
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
            }


            $AssetTagDisplay = $tsvarobj.Value("SVHAAssetTag")
            Write-Host "Asset Tag has been set to" $AssetTagDisplay -ForegroundColor Green
        }
        else {

            Write-Host "Asset Tag: FAIL" -ForegroundColor Red
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
        $tsvarobj.Value("SVHAWindowsVersion") = "10"
        if ($tsvarobj.Value("SVHAWindowsVersion") -eq "10") {
            Write-Host "Windows 10 Variable: OK" -ForegroundColor Green
        }
        else {
            Write-Host "Windows 10 Variable: FAIL" -ForegroundColor Red
        }

        #Set CustomWindowsVersion variable
        $tsvarobj.Value("CustomWindowsVersion") = "1709"
        if ($tsvarobj.Value("CustomWindowsVersion") -eq "1709") {
            Write-Host "Custom Domain Variable: OK" -ForegroundColor Green
        }
        else {
            Write-Host "CustomWindowsVersion Variable: FAIL" -ForegroundColor Red
        }

        #Set SVHAOffice variable
        $tsvarobj.Value("SVHAOffice") = "VLK86"
        if ($tsvarobj.Value("SVHAOffice") -eq "VLK86") {
            Write-Host "Office Variable: OK" -ForegroundColor Green
        }
        else {
            Write-Host "Office Variable: FAIL" -ForegroundColor Red
        }

        #Write TSVariable to notify TS that options are set
        $tsvarobj.Value("SVHAData3Options") = "True"
        if ($tsvarobj.Value("SVHAData3Options") -eq "True") {
            Write-Host "Data#3 Options Variable: OK" -ForegroundColor Green
        }
        else {
            Write-Host "Data#3 Options Variable: FAIL" -ForegroundColor Red
        }

        Write-Host "Setting Variables Complete." -ForegroundColor Green
        Start-Sleep
        exit 0
    }
    else {
        Write-Host "Computer is not located at Data#3" -ForegroundColor Green
        Write-Host
        Start-Sleep 5
        exit 0
    }

}

if ($Drivers) {
    Write-Host "Starting driver application... Please wait..." -ForegroundColor Green
    Start-Sleep -Seconds 3    
    Clear-Host

    ## INTRO BANNER AND INFORMATION ##
    # Write Random Banner in Window
    $BannerOptions = Get-ChildItem .\banners\DriversBanner*
    $ChosenBanner = Get-Random -InputObject $BannerOptions

    Write-Host
    Get-Content $ChosenBanner
    Write-Host
    Write-Host

    # Reading TS Variables and WMI
    $Model = (Get-WmiObject Win32_ComputerSystem).Model
    Write-Host "Model: $Model"

    # $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
    # $DriverLocationTSVAR = $tsenv.Value("SVHADriverSourceLocation")
    # Write-Host "Driver Source Location:" $DriverLocationTSVAR

    Write-Host "Attempting to apply drivers to image via DISM"
    Write-Host

    Start-Sleep 5
    Write-Host " " -NoNewline -ForegroundColor Yellow 

    $anim=@("|","/","-","\","|") # Animation sequence characters
    $jobName = Start-Job -ScriptBlock { DISM.exe /Image:C:\ /Add-Driver /Driver:C:\Windows\Temp\SVHADrivers /Recurse }
    while ($jobName.State -eq "Running") {
        $anim | % {
        Write-Host "`b$_" -NoNewline -ForegroundColor Yellow 
        Start-Sleep -m 50
        }
    }
    Write-Host
    Write-Host
    Write-Host "Driver Application Successful." -ForegroundColor Green
    Write-Host "Build will now proceed." -ForegroundColor Green
    Write-Host
    Start-Sleep -Seconds 5
}

if ($Apps) {
    Write-Host "Starting app installs... Please wait..." -ForegroundColor Green
    Start-Sleep -Seconds 3    
    Clear-Host

    # Declare Variables
    $LogLocation = "C:\Windows\Temp\Start-AppInstall.log"
    Write-CMTraceLog -LogFile $LogLocation -Message 'Reading declared variables.' -Type Information
    $AppListLocation = ".\files\applist.txt"
    $InstallsSuccessful = $true
    Write-CMTraceLog -LogFile $LogLocation -Message 'Variable declaration complete.' -Type Information


    # Hide ProgressUI to prevent it showing on top
    #Write-CMTraceLog -LogFile $LogLocation -Message 'Attempting to hide TSUI.' -Type Information
    #$TSProgressUI = new-object -comobject Microsoft.SMS.TSProgressUI
    #$TSProgressUI.CloseProgressDialog()
    #Write-CMTraceLog -LogFile $LogLocation -Message 'TSUI hide successful.' -Type Information

    # TEST PAUSE
    # Pause

    ## INTRO BANNER AND INFORMATION ##
    # Write Random Banner in Window
    Write-CMTraceLog -LogFile $LogLocation -Message 'Displaying banner.' -Type Information
    $BannerOptions = Get-ChildItem .\banners\AppsBanner*
    $ChosenBanner = Get-Random -InputObject $BannerOptions

    Write-Host
    Get-Content $ChosenBanner
    Write-Host
    Write-Host

    Write-Host "This installation was created to troubleshoot sporadic issues with the installation"
    Write-Host "of Java on the SVHA MOE. This script will attempt to install Java and, in the event"
    Write-Host "of a failure, provide guidance to ensure the build completes."
    Write-Host

    # Import list of apps to install and their 
    Write-CMTraceLog -LogFile $LogLocation -Message 'Importing app list and saving count.' -Type Information
    $AppsToInstall = Import-CSV -Path "$AppListLocation" -Delimiter ","
    $AppsToInstallCount = $AppsToInstall.Count
    Write-CMTraceLog -LogFile $LogLocation -Message 'App list import successful.' -Type Information

    # Display list of apps on screen
    Write-Host "List of apps imported to install:"
    ForEach ($Product in $AppsToInstall) {
        Write-Host "   - " $Product.name -ForegroundColor Yellow
    }
    Write-Host "Count: $AppsToInstallCount"
    Write-Host
    Write-Host "-------"
    Write-Host
    Write-Host "Starting install of software."
    Start-Sleep 2
    $counter = 0
    Write-CMTraceLog -LogFile $LogLocation -Message 'Starting ForEach loop.' -Type Information
    ForEach ($PendingInstall in $AppsToInstall) {
        
        # Reset variables.... Just in case
        Write-CMTraceLog -LogFile $LogLocation -Message 'Clearing variables in foreach loop.' -Type Information
        Write-Host "Clearing Variables... " -NoNewline
        $InstallExecutable = $null
        $InstallPath = $null
        $FullFilePath = $null
        $InstallName = $null
        $InstallArguments = $null
        Start-Sleep 1
        Write-Host "Success!" -ForegroundColor Green

        # Populate variables for current install
        Write-Host "Generating App Specific Variables... " -NoNewline
        $InstallExecutable = $PendingInstall.InstallFile
        $InstallPath = $PendingInstall.InstallPath
        $FullFilePath = Join-Path -Path $InstallPath -ChildPath $InstallExecutable
        $InstallName = $PendingInstall.Name
        $InstallArguments = $PendingInstall.Arguments
        $InstallType = $PendingInstall.InstallType
        Start-Sleep 1
        Write-Host "Success!" -ForegroundColor Green
        Write-Host "   Name: $InstallName" -ForegroundColor Yellow
        Write-Host "   Executable: $InstallExecutable" -ForegroundColor Yellow
        Write-Host "   Full File Path: $FullFilePath" -ForegroundColor Yellow
        Write-Host "   Args: $InstallArguments" -ForegroundColor Yellow
        Write-Host "   Install Type: $InstallType" -ForegroundColor Yellow
        
        # Increment counter.
        Write-Host "Incrementing Counter... " -NoNewline
        $counter++
        Start-Sleep 1
        Write-Host "Success!" -ForegroundColor Green

        #Update progress bar
        Write-Progress -Activity "Installing Application List" -CurrentOperation "Installing $InstallName" -PercentComplete (($counter / $AppsToInstallCount) * 100)
        Write-Host "Attemping install of $Installname... " -NoNewline
        Write-Host "In Progress" -ForegroundColor Yellow -NoNewline

        # Check if install type is EXE
        Write-CMTraceLog -LogFile $LogLocation -Message 'Beginning app install if checks' -Type Information
        If ($InstallType -eq "exe") {
            Try {
                Write-CMTraceLog -LogFile $LogLocation -Message "Starting install of $InstallName." -Type Information
                Start-Process -FilePath "$FullFilePath" -ArgumentList $InstallArguments -NoNewWindow -Wait
                Write-CMTraceLog -LogFile $LogLocation -Message "Completed install of $InstallName." -Type Information
                Write-Host "`b`b`b`b`b`b`b`b`b`b`bSuccess!   " -ForegroundColor Green
            }
            Catch {
                Write-CMTraceLog -LogFile $LogLocation -Logfile $LogLocation -Message $Error[0] -Type Error
                Write-Host "`b`b`b`b`b`b`b`b`b`b`bJawa Unsuccessful!" -ForegroundColor Red
                $InstallsSuccessful = $false
            }
        }

        # Need to include MSI functionality
        ### TODO ###
        Write-Host
    }

    If ($InstallsSuccessful) {
        Write-CMTraceLog -LogFile $LogLocation -Message "Script complete." -Type Information
        Write-Host
        Write-Host "Installs were successful. Exiting." -ForegroundColor Green
        Start-Sleep 5

        # TEST PAUSE
        # Pause
    }
    Else {
        Write-Host
        Write-Host "Installs were not successful. Please take note of incomplete installs and add to appropriate AD group." -ForegroundColor Red
        Pause
    }
}

if ($SurfaceAssetTag) {

    Write-Host "Starting Surface Pro asset tag application... Please wait..." -ForegroundColor Green
    Start-Sleep -Seconds 3    
    Clear-Host

    ## INTRO BANNER AND INFORMATION ##
    # Write Random Banner in Window
    $BannerOptions = Get-ChildItem .\banners\SurfaceBanner*
    $ChosenBanner = Get-Random -InputObject $BannerOptions

    Write-Host
    Get-Content $ChosenBanner
    Write-Host
    Write-Host

    Write-Host "Surface Pro Asset Tag Utility"
    Write-Host "-----------------------------"
    
    $CurrentSurfaceAssetTag = (Get-WmiObject -query "Select * from Win32_SystemEnclosure").SMBiosAssetTag
    Write-Host "Current Asset Tag: " -NoNewline

    if ($CurrentSurfaceAssetTag -eq "") {
        Write-Host "Not Set!" -ForegroundColor Red
        Write-Host
        Write-Host "The script will now attempt to set the asset tag for you."
        
        $ValidTagEntered = $false
        $ValidTagEasterEgg = 0
        do {
            if ($ValidTagEasterEgg -eq 2) {
                Write-Host "I'll give you a hint... Its 6 digits..." -ForegroundColor Yellow
            }
            if ($ValidTagEasterEgg -eq 3) {
                Write-Host "Valid options are 1,2,3,4,5,6,7,8,9,0..." -ForegroundColor Yellow
            }
            if ($ValidTagEasterEgg -eq 4) {
                Write-Host "You might want to ask someone for help." -ForegroundColor Yellow
            } 
            $ReadAssetFromUser = Read-Host "Please enter the 6 digit asset number..."
            if ($ReadAssetFromUser -match "^\d{6}$") {
                Write-Host "Thank you!" -ForegroundColor Green
                $ValidTagEntered = $True
            }
            else {
                Write-Host "Invalid asset tag entered..." -ForegroundColor Red
                Write-Host
                $ValidTagEasterEgg++
            }
        }
        While ($ValidTagEntered -eq $false)

        Write-Host
        Write-Host "Now attempting to write asset tag to hardware."

        .\resources\microsoft-assettagutility\AssetTag.exe -s "$ReadAssetFromUser"

        $tsvarobj = New-Object -COMObject Microsoft.SMS.TSEnvironment
        $tsvarobj.Value("SVHATagRestartRequired") = "True"

        Write-Host The computer will now be restarted to complete the operation.
        Start-Sleep -Seconds 5
        exit 1641

    }
    else {
        Write-Host "$CurrentSurfaceAssetTag" -ForegroundColor Green
        Write-Host "Asset Tag Follows Standard: " -NoNewline
        
        if ($CurrentSurfaceAssetTag -match "^\d{6}$") {
            Write-Host "True" -ForegroundColor Green
            Write-Host
            Write-Host "Asset Tag is set correctly. Continuing." -ForegroundColor Green
            Start-Sleep 5
        }

        else {
            Write-Host "False" -ForegroundColor Red
            Write-Host
            Write-Host "Removing incorrect asset tag."

            .\resources\microsoft-assettagutility\AssetTag.exe -s

            $ValidTagEntered = $false
            $ValidTagEasterEgg = 0
            do {
                if ($ValidTagEasterEgg -eq 2) {
                    Write-Host "I'll give you a hint... Its 6 digits..." -ForegroundColor Yellow
                }
                if ($ValidTagEasterEgg -eq 3) {
                    Write-Host "Valid options are 1,2,3,4,5,6,7,8,9,0..." -ForegroundColor Yellow
                }
                if ($ValidTagEasterEgg -eq 4) {
                    Write-Host "You might want to ask someone for help." -ForegroundColor Yellow
                } 
                $ReadAssetFromUser = Read-Host "Please enter the 6 digit asset number..."
                if ($ReadAssetFromUser -match "^\d{6}$") {
                    Write-Host "Thank you!" -ForegroundColor Green
                    $ValidTagEntered = $True
                }
                else {
                    Write-Host "Invalid asset tag entered..." -ForegroundColor Red
                    Write-Host
                    $ValidTagEasterEgg++
                }
            }
            While ($ValidTagEntered -eq $false)

            Write-Host "Now attempting to write asset tag to hardware."

            .\resources\microsoft-assettagutility\AssetTag.exe -s "N$ReadAssetFromUser"

            Write-Host The computer will now be restarted to complete the operation.
            Start-Sleep -Seconds 5
            exit 1641
        }
    }

}

if ($Unsuccessful) {
    # Read TS Variables
    $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
    $HostNameTSVAR = $tsenv.Value("OSDComputerName")
    Write-Host "Host name:" $HostNameTSVAR

    $LogLocTSVAR = $tsenv.Value("_smstslogpath")
    Write-Host "Log location:" $LogLocTSVAR

    $TSNameTSVAR = $tsenv.Value("_SMSTSPackageName")
    Write-Host "Task Sequence Name:" $TSNameTSVAR

    $TSAdvertIDTSVAR = $tsenv.Value("_SMSTSAdvertID")
    Write-Host "Advert ID:" $TSAdvertIDTSVAR

    # Generate Date/Time for logs
    $LogTimestamp = Get-Date -Format o | ForEach-Object {$_ -replace ":", "."}
    $FileName = "$HostNameTSVAR--$LogTimestamp"
    Write-Host "Timestamp:" $LogTimestamp

    Write-Host
    Write-Host "Attempting Log copy:"
    Write-Host "- Checking WinPE and log directory health... Success!" -ForegroundColor Green

    # Map drive and copy log files
    Try {
        New-PSDrive -Name "T" -PSProvider "FileSystem" -Root "\\SCCM-PR9-01.svhanational.org.au\BuildShare$" | Out-Null
        Write-Host "- Attempting to map drive to SCCM server... Success!" -ForegroundColor Green
        $MapSuccessful = $True
    }
    Catch {
        Write-Warning "- Attempting to map drive to SCCM server... Failed!" -ForegroundColor Red
        $MapSuccessful = $False
    }

    IF ($MapSuccessful -eq "True") {
        Try {
            New-Item -ItemType directory -Path "T:\Logs\$FileName" | Out-Null
            Write-Host "- Attempting to create log folder... Success!" -ForegroundColor Green
        }
        Catch {
            Write-Host "- Attempting to create log folder... Failed!" -ForegroundColor Red
        }
        
        # Log copy
        Try {
            Copy-Item -Path "$LogLocTSVAR\*.*" -Destination "T:\Logs\$FileName"
            Write-Host "- Attempting to copy logs... Success!" -ForegroundColor Green
        }
        Catch {
            Write-Host "- Attempting to copy logs... Failed!" -ForegroundColor Red
        }

        <# Notification email
        Try {
            Send-MailMessage -To "Adam.Stevens@svha.org.au" -From "svha.builds@svha.org.au" -Subject "Build Failed - $HostNameTSVAR" -Body "$Filename" -SmtpServer mail.svha.org.au
            Write-Host "- Sending notification email... Success!" -ForegroundColor Green
        }
        Catch {
            Write-Host "- Sending notification email... Failed!" -ForegroundColor Red
        }#>

        Write-Host
        Write-Host "THE TASK SEQUENCE IS INCOMPLETE" -ForegroundColor Red
        Write-Host "Logs have been uploaded to a network location for review." -ForegroundColor Red
        Write-Host "Please reattempt the build. If it continues to fail please contact a system administrator." -ForegroundColor Red
        Write-Host
        Write-Host
        Write-Host "$FileName" -ForegroundColor Yellow
        Write-Host
        
        write-host "Press any key to continue..."
        [void][System.Console]::ReadKey($true)

    }
    ELSE {

        Write-Host "THE TASK SEQUENCE IS INCOMPLETE" -ForegroundColor Red
        Write-Host "Log upload has failed." -ForegroundColor Red
        Write-Host "Please reattempt the build. If it continues to fail please contact a system administrator." -ForegroundColor Red
        
        write-host "Press any key to continue..."
        [void][System.Console]::ReadKey($true)

    }
}

if (!$TestSwitch -and !$Data3 -and !$Apps -and !$Drivers -and !$SurfaceAssetTag ) {
    Write-Warning "No switch has been provided. Script will exit without action." 
    Write-Host
    Write-Host "Please ensure you use one of the following switches:" -ForegroundColor Yellow
    Write-Host "  - Drivers" -ForegroundColor Yellow
    Write-Host "  - Apps" -ForegroundColor Yellow
    Write-Host "  - Data3" -ForegroundColor Yellow
    Write-Host "  - SurfaceAssetTag" -ForegroundColor Yellow
    Write-Host
    Start-Sleep -Seconds 10
}




