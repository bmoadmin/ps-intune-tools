<#
    .SYNOPSIS
      Disables the fast boot feature for Windows 10 endpoints

    .DESCRIPTION
      By modifying the local machines registry hive, this script disables Windows10 fast boot for anyone who logs into the machine.

      The registry key is HiberbootEnabled under power settings in the HKLM hive.
	
    .NOTES
      Name    : Disable-FastBoot
      Author  : bmoadmin
      Github  : https://github.com/bmoadmin
      Created : 04/26/2021
#>

if($(Get-ItemPropertyValue -Path "Registry::HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name HiberbootEnabled -ErrorAction SilentlyContinue) -ne 0)
{
    Set-ItemProperty -Path "Registry::HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name HiberbootEnabled -Value 0 -Force
}