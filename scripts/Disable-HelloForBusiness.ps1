<#
    .SYNOPSIS
      Disables Windows Hello for Business for all users.

    .DESCRIPTION
      By modifying the local machines registry hive, this script disables Windows Hello for Business for anyone who logs into the machine.

      The property is controlled by the PassportForWork\Enabled registry key under the HKLM hive.
	
    .NOTES
      Name    : Disable-HelloForBusiness
      Author  : bmoadmin
      Github  : https://github.com/bmoadmin
      Created : 01/26/2021
#>

if(Get-Item -Path 'Registry::HKLM\SOFTWARE\Policies\Microsoft\PassportForWork' -ErrorAction SilentlyContinue) 
{
    if(Get-ItemProperty -Path 'Registry::HKLM\SOFTWARE\Policies\Microsoft\PassportForWork' -Name Enabled -ErrorAction SilentlyContinue) 
    {
        Set-ItemProperty -Path 'Registry::HKLM\SOFTWARE\Policies\Microsoft\PassportForWork' -Name Value -Value 0 -Force
    } 
    else 
    {
        New-ItemProperty -Path 'Registry::HKLM\SOFTWARE\Policies\Microsoft\PassportForWork' -Name Enabled -PropertyType DWord -Value 0 -Force
    }
} 
else 
{
    New-Item -Path 'Registry::HKLM\SOFTWARE\Policies\Microsoft\PassportForWork' -Force     
    New-ItemProperty -Path 'Registry::HKLM\SOFTWARE\Policies\Microsoft\PassportForWork' -Name Enabled -PropertyType DWord -Value 0 -Force
}