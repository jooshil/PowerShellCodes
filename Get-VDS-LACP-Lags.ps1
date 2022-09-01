.<#
.SYNOPSIS
    Get-VDS-LACP-Lags
.DESCRIPTION
    get list of Lags on a VDS switch 
.NOTES
    exports the results to a csv 
.LINK
    
.EXAMPLE
    
#>

# connect to the vCenter 
Connect-VIServer xxxx

# Get VDS's used for vSAN 
$vds_list = Get-VDSwitch | where { $_.Name -like "*vsan*" }

foreach ($vds in $vds_list) {

    $lacpConfig = $vds.ExtensionData.Config.LacpGroupConfig

    $lacpConfig |Select Name, Mode, UplinkNum, LoadbalanceAlgorithm,UplinkName|Export-Csv .\VDS_LACP_Lags.csv -Append -Delimiter ","


}



