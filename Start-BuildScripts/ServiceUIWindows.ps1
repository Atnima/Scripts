param ( $script )
# This is a wrapper for SCCM – use as a package source with the real script as an argument.
.\ServiceUI.exe -process:tsprogressui.exe C:\Windows\System32\WindowsPowershell\v1.0\powershell.exe -ExecutionPolicy Bypass $script

exit 0