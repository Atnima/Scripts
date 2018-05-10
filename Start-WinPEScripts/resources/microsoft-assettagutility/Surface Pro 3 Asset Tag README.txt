This tool gets or sets the proposed Asset Tag, which will be applied on next reboot.

The current Asset Tag is an SMBIOS setting which can be queried via WMI:
  (Get-WmiObject -query "Select * from Win32_SystemEnclosure").SMBiosAssetTag

Get proposed asset tag:
  AssetTag -g

Clear proposed asset tag:
  AssetTag -s

Set proposed asset tag:
  AssetTag -s ABc-45.67

Valid values:
  The asset tag can be up to 36 characters long.
  Valid characters include A-Z, a-z, 0-9, period and hyphen.

PowerShell script demonstrating way to get proposed value and interpret errors.
Note that stout contains the Asset Tag and stderr contains error messages.

  AssetTag -g > $asset_tag 2> $error_message
  $asset_tag_return_code = $LASTEXITCODE
  $asset_tag = $asset_tag.Trim("`r`n")

  if ($asset_tag_return_code -eq 0) {
      Write-Output ("Good Tag = " + $asset_tag)
  } else {
      Write-Output (
          "Failure: Code = " + $asset_tag_return_code +
          "Tag = " + $asset_tag +
          "Message = " + $error_message)
  }

