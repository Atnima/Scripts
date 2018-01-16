$FilePath = "$env:windir\System32\drivers\etc\hosts"
$HostsFile = Get-Content $FilePath
$LinePresent = $Null
$BuildType = (Get-ItemProperty hklm:\software\svha\).BuildType


ForEach ($Line in $HostsFile) {
    If ($Line -eq "203.4.221.59 adfs.svha.org.au") {
        Write-Host "Line exists, setting variable"
        $LinePresent = $True
    }
    Else {
        Write-Host "Line does not match"

    }
}


If ($BuildType -eq "SomethingKiosk") {

    If ($LinePresent -eq $True) {
        Return $True
    }
    Else {
        Return $False
    }

}

If ($BuildType -ne "SomethingKiosk" -or $BuildType -eq $Null) {

    If ($LinePresent -eq $False) {
        Return $True
    }
    Else {
        Return $False
    }

}