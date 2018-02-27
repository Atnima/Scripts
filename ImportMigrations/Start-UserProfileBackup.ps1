$FoldersToCopy = @(
    'Desktop'
    'Downloads'
    'Favorites'
    'Documents'
    'Pictures'
    'Videos'
    )
    #'AppData\Local\Google'

$ListofUserProfiles = Get-ChildItem -Path "C:\Users" -Directory
$ComputerName = (Get-WMIObject Win32_ComputerSystem).Name
$Timestamp = Get-Date -Format o | ForEach-Object {$_ -replace ":", "."}

Try {
    New-PSDrive -Name "Z" -PSProvider "FileSystem" -Root "\\SCCM-PR9-01.svhanational.org.au\BackupShare$" | Out-Null
    Write-Verbose "- Attempting to map drive to SCCM server... Success!"
    $MapSuccessful = $True
}
Catch {
    Write-Warning "- Attempting to map drive to SCCM server... Failed!" -ForegroundColor Red
    Exit 1
}

Try {
    New-Item -ItemType directory -Path "Z:\" -Name "$ComputerName-$Timestamp" | Out-Null
    $BackupDirectory = "Z:\$ComputerName-$Timestamp\"
    Write-Verbose "- Attempting to create PC backup folder... Success!"
}
Catch {
    Write-Warning "- Attempting to create PC backup folder... Failed!"
}

ForEach ($User in $ListofUserProfiles | Where {$_.Name -notlike "Administrator" -and $_.Name -notlike "Public"}) {
    Write-Verbose "$User"
    $SourceRoot = "C:\Users\$User"
    $DestinationRoot = "$BackupDirectory\$User"

    ForEach ($Folder in $FoldersToCopy) {
        $Source      = Join-Path -Path $SourceRoot -ChildPath $Folder
        $Destination = Join-Path -Path $DestinationRoot -ChildPath $Folder

        Write-Verbose "Attempting to copy $Source"

        if ( -not ( Test-Path -Path $Source -PathType Container ) ) {
            Write-Warning "Could not find path`t$Source"
            continue
        }

        Copy-Item $Source $Destination -Recurse
        
    }
}

##$SourceRoot      = "C:\Users\$User"
##$DestinationRoot = "\\sccm-pr9-01.svhanational.org.au\e$\Source$\OSD\BuildShare\Backups"