Function Set-PowerPlanSettings
{
    <#
        .SYNOPSIS
          Set one or more power plan settings. 

        .DESCRIPTION 
          This script calls the root\cimv2\power namespace for the Win32 power plan options (normally only available in the control panel).  

        .PARAMETER SleepAfter
          Number of minutes before the computer is idle before going into sleep. Setting to 0 disables idle sleep.

        .PARAMETER HibernateAfter
          Number of minutes before the computer is idle before going into hibernate. Setting to 0 disables idle hibernate.

        .PARAMETER TurnOffHardDiskAfter
          Number of minutes before the computer is idle before the hard disk turns off and goes into power saving mode. Setting to 0 disables this behaivior. 

        .EXAMPLE
          Set-PowerPlanSettings -SleepAfter 30 -HibernateAfter 90 -TurnOffHardDiskAfter 0

          Set the idle time for sleep to 30 minutes, hibernation to 90 minutes, and disable turning the hard disk off to save power.
      
        .NOTES
          Name    : Set-PowerPlanSettings
          Author  : bmoadmin
          Github  : https://github.com/bmoadmin
          Created : 05/04/2021

          Reference: 
            This script is based off the following PowerShell module => https://github.com/bmoadmin/PowerplanUtils
    #>
    [CmdletBinding()]
    Param 
    (
        [Parameter(
            ParameterSetName = "ActionItems"
        )]
        [int]$SleepAfter,
        [int]$HibernateAfter,
        [int]$TurnOffHardDiskAfter
    )

    ###############
    #  Functions  #
    ###############

    Function Get-PowerPlanId 
    {
        <#
            .Description
              Get the UID of the currently active power plan and do some regex to clean up the returned string
        #>
        ((Get-CimInstance -Namespace "root\cimv2\power" -ClassName Win32_PowerPlan | Where-Object{ `
            $_.IsActive -eq $True
        }).InstanceID).Replace("Microsoft:PowerPlan\","")
    }

    Function Get-PowerPlanSettingId 
    {
        <#
            .Description
              Get the UID of the particular power setting in question, needed to set the value later
        
            .Parameter Name
              The name of the power setting to pull the UID of
        
            .Example
              Get-PowerPlanSettingId -Name "Hibernate after"
        #>
        [CmdletBinding()]
        Param 
        (
            [Parameter(
                Mandatory = $True
            )]
            [string]$Name
        )
        ((Get-CimInstance -Namespace "root\cimv2\power" -ClassName Win32_PowerSetting | Where-Object{ `
            $_.ElementName -eq "$Name"
        }).InstanceID).Replace("Microsoft:PowerSetting\","")
    }

    Function Get-PowerPlanSettingValue 
    {
        <#
            .Description
              Return the value of a specific setting as a PS object we can use to then set it to our desired value later
            
            .PARAMETER InputPowerPlanId
              The UID of the power plan returned by the Get-PowerPlan function

            .PARAMETER InputSettingId
              The UID of the specific power setting returned by the Get-PowerPlanSettingId function
        #>
        [CmdletBinding()]
        Param 
        (
            [Parameter(
                Mandatory = $True 
            )]
            [string]$InputPowerPlanId,
            [string]$InputSettingId
        )
        
        Get-CimInstance -Namespace "root\cimv2\power" -ClassName Win32_PowerSettingDataIndex `
        -Filter "InstanceID like '%$InputPowerPlanId%AC%$InputSettingId%'"
    }

    ###############
    #  Variables  #
    ###############

    $ActivePowerPlanId = Get-PowerPlanId

    ##########
    #  Main  #
    ##########

    # Loop through each parameter that was defined by the command, get the value, and set the appropriate power setting only if the param was defined. 
    ForEach($boundParam in $PSBoundParameters.GetEnumerator())
    {
        if($boundParam.Key -eq 'SleepAfter')
        {
            $SleepAfterId = Get-PowerPlanSettingId -Name "Sleep after"
            $SleepAfterTime = Get-PowerPlanSettingValue -InputPowerPlanId $ActivePowerPlanId -InputSettingId $SleepAfterId

            $SleepAfterTime | Set-CimInstance -Property @{SettingIndexValue = ([int]$SleepAfter * 60)}
        }
        elseif($boundParam.Key -eq 'HibernateAfter')
        {
            $HibernateAfterId = Get-PowerPlanSettingId -Name "Hibernate after"
            $HibernateAfterTime = Get-PowerPlanSettingValue -InputPowerPlanId $ActivePowerPlanId -InputSettingId $HibernateAfterId

            $HibernateAfterTime | Set-CimInstance -Property @{SettingIndexValue = ([int]$HibernateAfter * 60)}
        }
        elseif($boundParam.Key -eq 'TurnOffHardDiskAfter')
        {
            $TurnOffHardDiskAfterId = Get-PowerPlanSettingId -Name "Turn off hard disk after"
            $TurnOffHardDiskAfterTime = Get-PowerPlanSettingValue -InputPowerPlanId $ActivePowerPlanId -InputSettingId $TurnOffHardDiskAfterId

            $TurnOffHardDiskAfterTime | Set-CimInstance -Property @{SettingIndexValue = ([int]$TurnOffHardDiskAfter * 60)}
        }
    }
}

#########################################
#  Set your power option settings here  #
#########################################

Set-PowerPlanSettings -SleepAfter 0 -HibernateAfter 0 -TurnOffHardDiskAfter 0