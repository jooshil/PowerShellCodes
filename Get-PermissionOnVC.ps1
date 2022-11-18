
<#
.SYNOPSIS
    Get-PermissiononVC
.DESCRIPTION
    verify a user is added to the list of vCenters and generate a report
    this scripy will create report on the status of teh user if its added to a VC or not 
.NOTES
    Provide the list of vCentersin the csv file with name as header 
.LINK
     
.EXAMPLE
   
#>



$vclist = import-csv .\VClist.csv


$cred = Get-Credential

foreach ($vc in $vclist) {

    Write-Host "Chcking Permission on VC" $vc.name 

    Connect-VIServer $vc.Name -Credential $cred

    $report = @()
    $info = "" | Select-Object vCenter, Principal, Role, Propagate
    # Give the user name that wanted check 
    $permission = get-VIPermission | ? { ($_.Principal -like "*svcvmvsphere*") }

    if ($null -eq $permission) {
        Write-Host $vc.name "not added with svcvmvsphere" -ForegroundColor Red
        $info.vCenter = $vc.Name
        $info.Principal = "Not Found"
        $info.Role = "N/A"
        $info.Propagate = "N/A"
        $report += $info
    }
    else {
        $info.vCenter = $vc.Name
        $info.Principal = $permission[0].Principal
        $info.Role = $permission[0].Role
        $info.Propagate = $permission[0].Propagate
        $report += $info      
    }
    
    $report | Export-Csv .\svcPermissionlist.csv -Append -Delimiter "," -NoTypeInformation
    Disconnect-VIServer * -Force -Confirm:$false

}
