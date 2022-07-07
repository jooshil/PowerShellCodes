
<#
.SYNOPSIS
    Get-VIPermission-ForSignleUser
.DESCRIPTION
    this scrpt extacts the vcenter rols and permission for a signle ser from list of VC's
.NOTES
    provide the list of vcenters with user name and password in a csv file 
.LINK
 
#>




$vclist = Import-Csv "C:\Scripts\VMC_Scripts\vmcvclist.csv"


foreach ($item in $vclist) {

Write-Host "checking on host" $item.vc
    Connect-VIServer $item.vc -User $item.user -Password $item.pass

    #$userpermission = Get-VIPermission | ? { ($_.Principal -like "*svcvraadadmin*") -or ($_.Principal -like "*svcvraadmin*") }

    $userpermission = Get-VIPermission | ? { ($_.Principal -like "*grop/username*") -or ($_.Principal -like "*grop/username*") }

    


    $userpermission | select @{N = "VCName"; E = { $item.vc } }, Principal, Role, Propagate, Entity | Export-Csv .\UserPermissionDataBuild.csv -NoTypeInformation -Append -Delimiter ","

    Disconnect-VIServer *   -Force:$true -Confirm:$false


}


# Remove Permission



foreach ($item in $vclist) {

    Write-Host "checking on host" $item.vc
        Connect-VIServer $item.vc -User $item.user -Password $item.pass
    
        $userpermission = Get-VIPermission | ? {($_.Principal -like "*usrname*") -and ($_.Role -like "*ReadOnly*") }

        
    
        Remove-VIPermission -Permission  $userpermission -Confirm:$false

        #$userpermission | select @{N = "VCName"; E = { $item.vc } }, Principal, Role, Propagate, Entity | Export-Csv .\UserPermissionDataRORemoval.csv -NoTypeInformation -Append -Delimiter ","
    
        #Disconnect-VIServer *   -Force:$true -Confirm:$false
    
    
    }

