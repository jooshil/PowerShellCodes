<#
.SYNOPSIS
Export the network Segments from given VMC SDDC list
.DESCRIPTION
This Script exports all list of the segmenst ceated on a VMC SDDC
.NOTES
Provie the SDDC name and Org as csv
vmwre VMC powershell mdodule need to be installed and powershell Version 7.xx required as well
.LINK



#>



$token = 'SHflAq6fLGwTgLV16kj3jYlvY3eONp44Gl9uM3JR-9COevv3fLzbV48MuhSlt7ju'
Connect-Vmc -RefreshToken $token
#Disconnect-Vmc -Confirm:$false



$org = (Get-VmcOrganization).Name



$sddcs = Get-vmcsddc



$outfile = ".\vmc_segments_List.csv"
$sddcs



foreach ($item in $sddcs) {
$sddcname = $item.Name



Write-Host "Connecting SDDC" $item.Name
Connect-Vmc -RefreshToken $token
Connect-NSXTProxy -RefreshToken $token -OrgName $org -SDDCName $sddcname



$method = "GET"
$segmentsURL = $global:nsxtProxyConnection.Server + "/policy/api/v1/infra/tier-1s/cgw/segments?page_size=100"
$requests = Invoke-WebRequest -Uri $segmentsURL -Method $method -Headers $global:nsxtProxyConnection.headers -SkipCertificateCheck



$segments = ($requests.Content | ConvertFrom-Json -AsHashtable).results
$results = @()
foreach ($segment in $segments) {



$tmp = [pscustomobject] @{
segmentName = $segment.display_name
segmentId = $segment.id
Network = ($segment.subnets).network
Gateway = ($segment.subnets).gateway_address
tag = ($segment.tags).tag
type = $segment.type
adminstate = $segment.admin_state
repmode = $segment.replication_mode
T1Name = $segment.connectivity_path
}
$results += $tmp

}



$results | select @{N = "SDDCName"; e = { $sddcname } }, @{N = "Version"; e = { $item.Version } },
@{N = "Region"; e = { $item.Region } }, @{N = "SddcGroup"; e = { $item.SddcGroup } },
@{N = "SddcGroupMemberConnectivityStatus"; e = { $item.SddcGroupMemberConnectivityStatus } },
@{N = "VCenterHostName"; e = { $item.VCenterHostName } }, segmentName, segmentId, Network, Gateway, tag, type, T1Name, adminstate, repmode
| Export-Csv -Path $outfile -Append -Delimiter "," -NoTypeInformation



Write-Host "Disconecting from Sddc after the Data collection "
Disconnect-Vmc -Confirm:$false
}