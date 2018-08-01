#ConfigMgr OSD Prestart Command Script to detect PeerCache avalable sources and enable PeerCache in OSD if yes

[void] [Reflection.Assembly]::LoadWithPartialName("System.Diagnostics")
[void] [Reflection.Assembly]::LoadFile("$PSSCriptRoot\Microsoft.ConfigurationManagement.Messaging.dll")
try  {
    $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
}
catch{
    Write-Output "No TS Environment found to write Variable to"
    break
}

$BootMediaSiteCode=$tsenv.Value("_SMSTSSiteCode")
Function check-ContentLocation{
param(
$sitecode=$tsenv.Value("_SMSTSSiteCode"),
$ManagementPoint=$tsenv.Value("SMSTSMP"),
[Parameter(Mandatory=$true)]$PkgID,
[Parameter(Mandatory=$true)]$PkgVer#,
#[Parameter(Mandatory=$true)]$ADSite
)
# Set up the objects
$httpSender = New-Object -TypeName Microsoft.ConfigurationManagement.Messaging.Sender.Http.HttpSender
$clr = New-Object -TypeName Microsoft.ConfigurationManagement.Messaging.Messages.ConfigMgrContentLocationRequest
$cmReply = New-Object -TypeName Microsoft.ConfigurationManagement.Messaging.Messages.ContentLocationReply


# Define our SCCM Settings for the message
$clr.SiteCode = $sitecode
$clr.Settings.HostName = $ManagementPoint
$clr.LocationRequest.Package.PackageId = $PkgId
$clr.LocationRequest.Package.Version = $PkgVer
$clr.LocationRequest.ContentLocationInfo.IPAddresses.DiscoverIPAddresses() | out-null
$clr.LocationRequest.ContentLocationInfo.AllowSuperPeer = 1

# Validate
$clr.Validate([Microsoft.ConfigurationManagement.Messaging.Framework.IMessageSender]$httpSender)
# Send the message
$cmReply = $clr.SendMessage($httpSender)
# Get response
$response = $cmReply.Body.Payload.ToString()
#$response
while($response[$response.Length -1] -ne '>'){$response = $response.TrimEnd($response[$response.Length -1])}
[xml]$t = $response
If($t.ContentLocationReply.Sites.Site.LocationRecords.LocationRecord.ServerRemotename)
{
    #$t.ContentLocationReply.Sites.Site.LocationRecords.LocationRecord.ServerRemotename 
    #$t.ContentLocationReply.Sites.Site.LocationRecords.LocationRecord.DPType
    #$t.ContentLocationReply.Sites.Site.LocationRecords.LocationRecord.Locality

    if ( $t.ContentLocationReply.Sites.Site.LocationRecords.LocationRecord.DPType -eq 'SUPERPEER') 
    {
        "Set SMSTSPeerDownload = TRUE"
        try  {
            $tsenv.Value("SMSTSPeerDownload") = "TRUE"
        }
        catch{
            Write-Output "No TS Environment found to write Variable to"
        }

        }
}Else{Write-Output "!!! ---> No Location found for $PkgId at $ADSite !!!!!"}
}

check-ContentLocation -PkgID 'PS10002f' -PkgVer 1
