#Function to set a new DRAC password for a given user. Requires "racadm" command to be in $ENV:path

 

Function Set-DracPassword {
  Param(
    [Parameter(Mandatory=$true)]$dracAddress,
    [Parameter(Mandatory=$true)]$userName,
    [Parameter(Mandatory=$true)]$oldPw,
    [Parameter(Mandatory=$true)]$newPw
  )
  $maxUsers=16 #Max Users on DRAC 7
  Write-Host "[$dracAddress] Checking Users (max $($maxUsers))... " -NoNewLine -ForegroundColor Yellow

 

  foreach ($Count in (1..$maxUsers)) {
    Write-Host "$($Count)=" -NoNewline
    $result = racadm -r $dracAddress -u $userName -p $oldPw getconfig -g cfgUserAdmin -i $count
    $gotUser = ($result | ? {$_ -match "^cfgUserAdminUserName"}).Split("=")[1]

 

    if ($userName -eq $gotUser) {
      Write-Host "$gotUser"
      Write-Host "Found Matching User, id=$($Count)"
      $Match = $True
      Break
    }
    Write-Host "$gotUser, " -NoNewline
  }  
  if ($Match) {
    Write-Host "Setting password for user $gotUser"
    $setResult = racadm -r $dracAddress -u $userName -p $oldPw config -g cfgUserAdmin -o cfgUserAdminPassword -i $count $newPw
    $setResult | ? {$_ -ne ""}
  } else {
    Write-Error "Username $userName not found (this should never happen!)"
  }
}
