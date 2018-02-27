# File path dialogue
Function Get-FileName($initialDirectory)
{  
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "Excel Workbook (*.xlsx)| *.xlsx"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-FileName

# *** Entry Point to Script ***


# Specify the path to the Excel file and the WorkSheet Name
$FilePath = Get-FileName -initialDirectory "c:\"
$SheetName = "Sheet1"

# Create an Object Excel.Application using Com interface
$objExcel = New-Object -ComObject Excel.Application

# Disable the 'visible' property so the document won't open in excel
$objExcel.Visible = $false

# Open the Excel file and save it in $WorkBook
Try {
    $WorkBook = $objExcel.Workbooks.Open($FilePath)
    Write-Host "- Attempting to open workbook... Success!" -ForegroundColor Green
}
Catch {
    Exit 1
}

# Load the WorkSheet 'BuildSpecs'
$WorkSheet = $WorkBook.sheets.item($SheetName)

## Read values
$rowMax = ($WorkSheet.UsedRange.Rows).count 
$RowNewPC,$ColNewPC = 1,1
$RowOldPC,$ColOldPC = 1,2
$DetailsArray = @()

for ($i=1; $i -le $rowMax-1; $i++) {
    $NewPC = $WorkSheet.Cells.Item($RowNewPC+$i,$ColNewPC).text
    $OldPC = $WorkSheet.Cells.Item($RowOldPC+$i,$ColOldPC).text

    $DetailsArray += "$NewPC,$OldPC"
}


Try {
    New-PSDrive -Name "T" -PSProvider "FileSystem" -Root "\\SCCM-PR9-01.svhanational.org.au\BuildShare$" | Out-Null
    Write-Host "- Attempting to map drive to SCCM server... Success!" -ForegroundColor Green
    $MapSuccessful = $True

    IF ($MapSuccessful -eq "True") {
        ForEach ($value in $DetailsArray) {
            Try {
                New-Item -ItemType file -Path "T:\MigrationBox\" -Name "$Value.queue" -Value "$Value" | Out-Null
                Write-Host "- Attempting to create migration queue... Success!" -ForegroundColor Green
            }
            Catch {
                Write-Host "- Attempting to create migration queue... Failed!" -ForegroundColor Red
            }

            <# Notification email
            Try {
                Send-MailMessage -To "Adam.Stevens@svha.org.au" -From "svha.builds@svha.org.au" -Subject "Migration Queued - $Value" -Body "$value" -SmtpServer mail.svha.org.au
                Write-Host "- Sending notification email... Success!" -ForegroundColor Green
            }
            Catch {
                Write-Host "- Sending notification email... Failed!" -ForegroundColor Red
            } #>
        }
    }   
}
Catch {
    Write-Warning "- Attempting to map drive to SCCM server... Failed!" -ForegroundColor Red
    $MapSuccessful = $False
}

    
    ## Continue migration here
    # Get credentials from running tech



# Close the Workbook
$WorkBook.Close()

# Quit the Excel instance
$objExcel.Quit()

# Release the com object
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($objExcel)