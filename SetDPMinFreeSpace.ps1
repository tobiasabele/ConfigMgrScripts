##    Adjust ReservedDiskSpace from DP
 
$sdkserver="SiteServer"
$siteCode="000"
$targetDp="\\\\DP.contoso.com"
 
$MinFreeSpaceValue = 2048
 
$dp = gwmi -computer $sdkserver -namespace "root\sms\site_$sitecode" -query "select * from SMS_SCI_SysResUse where RoleName = 'SMS Distribution Point' and NetworkOSPath = '$targetDp'"
 
$props = $dp.Props 
$prop = $props | where {$_.PropertyName -eq "MinFreeSpace" }
 
Write-Output "Current DistributionPoint MinFreeSpace = " $prop.Value
 
$prop.Value = $MinFreeSpaceValue
 
Write-Output "Updating the DistributionPoint MinFreeSpace to = " $MinFreeSpaceValue
 
$dp.Props = $props
$dp.Put()
