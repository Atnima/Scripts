
$ISSETUP_PATH = 'C:\Program Files (x86)\Inno Setup 5\ISCC.exe'
$DPINST_PATH = 'C:\Temp\github\Tools\DPInst'
$DRIVERPACKAGEPATH = 'C:\TEMP'

function New-EXEDriverPackage
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        $Path,
        [Parameter(Mandatory=$true)]
        $Vendor,
        [Parameter(Mandatory=$true)]
        $Model,
        [Parameter(Mandatory=$true)]
        [ValidateSet('Windows-10', 'Windows-81', 'Windows-7')]
        $OperatingSystem,
        [Parameter(Mandatory=$true)]
        [ValidateSet('x86', 'x64')]
        $Architecture,
        [DateTime]$PublishedDate = $(Get-Date)
    )

    Process
    {
        $driverPackageName = "$($Vendor.Replace('.','').Replace(' ', '-')).$($Model.Replace('.','').Replace(' ', '-')).$($OperatingSystem.Replace('.','').Replace(' ', '-')).$($Architecture.Replace('.','').Replace(' ', '-')).$(($PublishedDate).ToString('yyyy-MM-dd'))"
        Write-Verbose $driverPackageName

        # generate dpinst.xml
        $xmlFile = '<dpinst><search>'
    
        foreach ($folder in $(Get-ChildItem "$Path" -Directory))
        {
            $xmlFile += "<subDirectory>$($folder.Name)</subDirectory>"
        }

        $xmlFile += '</search></dpinst>'

        [xml]$xmlResult = $xmlFile
        $stringWriter = New-Object System.IO.StringWriter 
        $xmlTextWriter = New-Object System.XMl.XmlTextWriter $stringWriter 
        $xmlTextWriter.Formatting = 'indented'
        $xmlTextWriter.Indentation = 4 
        $xmlResult.WriteContentTo($xmlTextWriter) 
        $xmlTextWriter.Flush() 
        $stringWriter.Flush() 

        $dpinstXml = $stringWriter.ToString()

        # generate setup.iss file
        $setupFile = @"
[Setup]
AppId={{$([System.Guid]::NewGuid())}
AppName=$Vendor $Model Driver Package
AppVersion=$(($PublishedDate).ToString('yyyyMMdd'))
AppPublisher=St Vincent's Health Australia
CreateAppDir=no
SolidCompression=yes

[Files]
Source: "$Path\*"; DestDir: "{tmp}"; Flags: ignoreversion recursesubdirs deleteafterinstall

[Run]
Filename: "{tmp}\dpinst.exe"; Parameters: "/q /s /sa";
"@

        if (-Not $(Test-Path -Path "$path\dpinst.exe"))
        {
            Copy-Item -Path "$DPINST_PATH\dpinst.exe" -Destination "$Path"
        }

        Set-Content -Path "$Path\dpinst.xml" -Value $dpinstXml

        $tempFileName = [System.IO.Path]::GetTempFileName()
        Set-Content -Path "$tempFileName" -Value $setupFile

        Start-Process -FilePath "$ISSETUP_PATH" -Wait -NoNewWindow -ArgumentList "/o""$($DRIVERPACKAGEPATH)\$($driverPackageName)"" /f""$($driverPackageName)"" ""$tempFileName"""
    }
}
