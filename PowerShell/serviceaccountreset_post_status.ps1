#Log Settngs
$Logfile = "<HOME_DIR>\ServiceAccountChange-Post.log"
function Get-TimeStamp {
    
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
    
}
Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value  $logstring
}
# Script location 
$ScriptPath = Split-Path -parent $MyInvocation.MyCommand.Definition 

 
# Array of Services which should be changed, Use the real "Display Name" of each Service 
$Srvs = ('<ServiceName>'); 
 
#Prompt for an administartiv user name and password  
#$Cred = Get-Credential -Credential "D2\UN1"
   
#Read the servers listed in the server.txt file located in the script folder 
$servers = Get-Content "$ScriptPath\serverList.txt" 
foreach ($server in $servers) 
{ 
# Stop, Configure and Restart of the listed Services above 
LogWrite "======================================$server===========================================";
foreach ($Srv in $Srvs)  
        { 
        try {
        $gsrv = Get-Service -DisplayName $Srv -Computername $server
        $DispName = $gsrv.DisplayName
		$GsrvStatus = $gsrv.status
        #$MachineName = $gsrv.machinename
		#Get-Service -DisplayName $srv -Computername $server #| out-File "<HOOME_DIR>\ServiceAccountChange.log" -Append	
        LogWrite "$(Get-TimeStamp) Service $DispName has status $GsrvStatus on $server  ";
        }
        catch {
        LogWrite "$(Get-TimeStamp) Service $srv has issue/error in $server";
        }
        } 
 } 