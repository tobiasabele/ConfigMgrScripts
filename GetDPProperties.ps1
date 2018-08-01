##    Get all properties of a DP from Site Control File

$sdkserver="SiteServer"
$siteCode="000"
$targetDp="\\\\DP.contoso.com"
 
$dp = gwmi -computer $sdkserver -namespace "root\sms\site_$sitecode" -query "select * from SMS_SCI_SysResUse where RoleName = 'SMS Distribution Point' and NetworkOSPath = '$targetDp'"
 
$props = $dp.Props 
foreach ($prop in $props)
{
    Write-Output "$($prop.PropertyName)  =  $($prop.Value)"
}
 
