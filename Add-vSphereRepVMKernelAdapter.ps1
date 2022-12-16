<#

.SYNOPSIS

    Add-vSphereRepVMKernelAdapter

.DESCRIPTION

    Add vSphereReplication VMK Adapters && Add Static Route to the hosts and

.NOTES

    the scrpt crete a new VMKernel Adapter with vSphere Repication enabled  and then add the static rout'

.LINK

    Specify a URI to a help page, this will show when Get-Help -Online is used.

.EXAMPLE

    Test-MyTestFunction -Verbose

    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines

#>


# Adding vSphere Replication VMkernel Adapter


$vsrpiplist = Import-Csv .\vsrp_ip_list.csv

foreach ($item in $vsrpiplist) {

    $esxName = $item.esxname

    $vdsName = $item.vdsname

    $pgName = $item.pgname

    $ipAddr = $item.ipaddr

    $ipMask = $item.subnetmsk



    $esx = Get-VMHost -Name $esxName

    Write-Host 'Configuring vSphere Replication Adapter on Host: ' $esxName -ForegroundColor Green

    $vmk = New-VMHostNetworkAdapter -VMHost $esx -PortGroup $pgName -IP $ipAddr -SubnetMask $ipMask -VirtualSwitch $vdsName -Mtu "8800"

    $vnicMgr = Get-View -Id $esx.ExtensionData.ConfigManager.VirtualNicManager

    $vnicMgr.SelectVnicForNicType('vSphereReplication', $vmk.Name)

    $vnicMgr.SelectVnicForNicType('vSphereReplicationNFC',$vmk.Name)



}



$Hostlist = Get-Cluster AM5_VC01_PROD_CORE_A | Get-VMHost


# vSphere Replication Destination Subnet and gateway(for AP1 dest subnet will be AP2 subnet and vise versa)



$dest = "10.228.216.0/22"  # AP2 vSrp subnet

$gw = "10.203.216.1"  # AP1 vSrp subnet gatway IP



foreach ($item in $Hostlist) {



    $esx = $item.name

    $esxcli = Get-EsxCli -VMHost $esx -V2

    $parms = @{network = $dest; gateway = $Gw }

   

    #Adding Static Route

    $esxcli.network.ip.route.ipv4.add.Invoke($parms)

       

    #List Static Route

    $esxcli.network.ip.route.ipv4.list.Invoke()

    $esxcli.network.ip.route.ipv4.list.Invoke() | Export-Csv .\StaticRoutes.csv -Append -Delimiter "," -NoClobber -NoTypeInformation




    <#$vmhostroute1 = New-VMHostRoute -VMHost 10.23.114.189 -Destination 192.168.104.101 -Gateway 10.23.84.69 -PrefixLength 32

    Set-VMHostRoute -VMHostRoute ($vmhostroute1, $vmhostroute2) -Destination 192.168.104.0 -PrefixLength 24

    #>

}
