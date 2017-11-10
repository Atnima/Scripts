$sitecode = "SVH"
 
$date = Get-Date -UFormat %m%d%Y_%H%M%S
$tsbackup = "C:\Temp\Backup_$date\"
 
if ([IntPtr]::size -ne 4) {
    write-error "This script must be ran with 32-bit PowerShell."
} else {
    $CMModule = 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
 
    if ($CMModule) {
        New-Item $tsbackup -ItemType directory | out-null
 
        $xsl = (Get-ChildItem $psscriptroot -File tsDocumentorv2.xsl).FullName
        Copy-Item $xsl -Destination $tsbackup -Verbose
 
        function Export-TaskSequences {
            param (
                $filter
            )            
 
            Import-Module $CMModule
            Set-Location $sitecode":"
 
            $tasksequences = Get-CMTaskSequence -Name $filter
       
            foreach ($ts in $tasksequences) {
                $tsname = $ts.Name
                
                write-host "`nTask Sequence:"$tsname
                $tspathxml = $tsbackup + "$tsname.xml"
                
                write-host "File Path:"$tspathxml
                Set-Location "c:\"
                
                Write-Output '<?xml-stylesheet type="text/xsl" href="tsDocumentorv2.xsl"?>' | Out-File $tspathxml
                $ts.Sequence | Out-File $tspathxml -Append
            }
        }
 
        Export-TaskSequences -filter "OSD - Capture*"       
    } else {
        write-error "Please install the Configuration Manager 2012 console first!"
    }
}

