$Results = @()
$RequiredData = Get-ADUser -filter * -properties *

ForEach ($Entry in $RequiredData) {

    $Results += $Entry | Select-Object SAMAccountName,EmployeeID,DisplayName

}

$Results | export-csv C:\Temp\QuickExport.csv -NoTypeInformation