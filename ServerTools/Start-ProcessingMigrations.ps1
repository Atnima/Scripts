$MigrationBoxLocation = "E:\Source$\OSD\BuildShare\MigrationBox"

$PendingMigrations = Get-ChildItem "$MigrationBoxLocation\*.queue"
ForEach ($Migration in $PendingMigrations) {
    # reset variables
    $FullMigrationDetails = $null
    $MigrationSplit = $null
    $ExistingPCFullDetails = $null
    $NewPCFullDetails = $null
    $ExistingPCFullDetailsConfirm = $false
    $NewPCFullDetailsConfirm = $false


    $FullMigrationDetails = Get-Content "$Migration"
    $MigrationSplit = $FullMigrationDetails.split("{,}")


    # Get old PC details from AD - assume if not present user has failed and move to failed
    Try {
        Get-ADComputer $MigrationSplit[1]
        $ExistingPCFullDetails = Get-ADComputer $MigrationSplit[1] -Properties *
        $ExistingPCFullDetailsConfirm = $true
    }
    Catch {
        # Computer name entered as existing PC does not exist
        Write-Verbose "Existing computer name should exist and doesn't."
        Try {
            Move-Item -Path "$Migration" -Destination "$MigrationBoxLocation\failed"
        }
        Catch {
            Write-Warning "Moving queue item failed."
        }
    }


    # Get new PC details from AD - Assume if not present, device is currently building and skip for this run
    Try {
        $NewPCFullDetails = Get-ADComputer $MigrationSplit[0] -Properties *
        $NewPCFullDetailsConfirm = $true
    }
    Catch {
        # Computer name entered as existing PC does not exist
        Write-Verbose "New computer name does not exist - continuing."
    }

    if ($ExistingPCFullDetailsConfirm -eq $true -and $NewPCFullDetailsConfirm -eq $true) {

        Write-Verbose "New and old PC details found. Attempting to transfer groups."
        $ExistingGroups = $ExistingPCFullDetails.MemberOf

        ForEach ($group in $ExistingGroups) {

            Add-ADGroupMember -Identity $group -Members $NewPCFullDetails

        }

        Move-Item -Path "$Migration" -Destination "$MigrationBoxLocation\success"

    }

}