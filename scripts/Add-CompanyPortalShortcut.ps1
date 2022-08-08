<#
    .SYNOPSIS
      Creates a shortcut to the company portal app.
        
    .DESCRIPTION
      Place a shortcut to the company portal app on Intune managed Windows endpoints on an end user's desktop folder.

      This script needs improvement as it currently does not contain any logic should the shortcut already exist and only works if the user is signed into onedrive.
         
    .NOTES
      Name    : Add-CompanyPortalShortcut
      Author  : bmoadmin
      Github  : https://github.com/bmoadmin
      Created : 04/11/2021
#>

$TargetFile = "C:\Windows\explorer.exe"
$ShortcutFile = "$env:OneDrive\Desktop\CompanyPortal.lnk"
$WScriptShell = New-Object -ComObject Wscript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.Arguments="shell:AppsFolder\Microsoft.CompanyPortal_8wekyb3d8bbwe!App"
$Shortcut.IconLocation = "https://deviceadvice.io/wp-content/uploads/2020/08/CompanyPortalApp.ico"
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()