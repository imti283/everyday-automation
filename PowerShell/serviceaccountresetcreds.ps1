<#
changed on 31st Jan to make it wokring on local servers.
Need to implement logging and dash feature for text logging
Need to check if sleep time need to changed
Need to implement same in rest servers though another server.
Logwrite implemented, live log(write host implemented)
Dash Feature implemented, need to be tested
Log Settings
#>
$Logfile = "<HOME_DIR>\ServiceAccountChange.log"
function Get-TimeStamp {
    
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
    
}

Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}
# Script location 
$ScriptPath = Split-Path -parent $MyInvocation.MyCommand.Definition 
 
# New Service Account 
$ServiceAccount = "<Acct>" 
$ServicePassword = "<pwd>" 
 
# Array of Services which should be changed, Use the real "Display Name" of each Service 
$Srvs = (<Comma Sep Service Names>); 
 
#Prompt for an administartiv user name and password  
#$Cred = Get-Credential -Credential "D1\UN1"
   
#Read the servers listed in the server.txt file located in the script folder 
$servers = Get-Content "$ScriptPath\ServerList.txt" 
foreach ($server in $servers) 
{ 
# Stop, Configure and Restart of the listed Services above 
LogWrite "======================================$server===========================================";
foreach ($Srv in $Srvs)  
        { 
        $gsrv = Get-Service -DisplayName $Srv -Computername $server
        $DispName = $gsrv.DisplayName
		$GsrvStatus = $gsrv.status
		#Get-Service -DisplayName $srv -Computername $server | out-File "C:\ServiceAccountChange.log" -Append
        Write-Host "Service $DispName has status $GsrvStatus on $server  ";
		Write-Host "Stopping the service $DispName on $server";
        LogWrite "$(Get-TimeStamp) Service $DispName has status $GsrvStatus on $server  ";
		LogWrite "$(Get-TimeStamp) Stopping the service $DispName on $server";
        Get-Service -Name $DispName -ComputerName $server | Set-Service -Status Stopped
        #Invoke-Command -Computername $server -ScriptBlock { Stop-Service -DisplayName $args[0] } -argumentlist $DispName
        Start-Sleep -s 10
        $lsrv = Get-Service -DisplayName $srv -Computername $server
		$lDispName = $lsrv.DisplayName
		$lLsrvstatus = $lsrv.status
		Write-Host "Service $lDispName has status $lLsrvstatus on $server" ;
        LogWrite "$(Get-TimeStamp) Service $lDispName has status $lLsrvstatus on $server" ;
        #Set-Service -DisplayName $srv -ComputerName $server -StartupType Automatic 
        $service = gwmi win32_service -ComputerName $server -filter "displayname='$Srv'"
        $service.Change($null, $null, $null, $null, $null, $null, $ServiceAccount, $ServicePassword).ReturnValue
		$srvChangeStatus = $service.Change().ReturnValue 
        # StatusRBSA
        Start-Sleep -s 5 
        if ($service.Change().ReturnValue -eq "0")  
            { 
            Write-Host "Logon successfully Changed with status $srvChangeStatus on $server"  
            LogWrite "$(Get-TimeStamp) Logon successfully Changed with status $srvChangeStatus on $server"  
            } 
        ELSE 
            { 
            Write-Host "Logon Account change Failed with status $srvChangeStatus on $server" 
            LogWrite "$(Get-TimeStamp) Logon Account change Failed with status $srvChangeStatus on $server" 
            } 
        #Start-Service -DisplayName $gsrv 
        Get-Service -Name $DispName -ComputerName $server | Set-Service -Status Running
        #Invoke-Command -Computername $server -ScriptBlock { Start-Service -DisplayName $args[0] } -argumentlist $DispName
        Start-Sleep -s 10
        $Asrv = Get-Service -DisplayName $srv -Computername $server
		$ADispName = $Asrv.DisplayName
		$Asrvstatus = $Asrv.status	
		Write-Host "Service $ADispName has status $Asrvstatus on $server" ;		
        LogWrite "$(Get-TimeStamp) Service $ADispName has status $Asrvstatus on $server" ;	
        } 
    } 