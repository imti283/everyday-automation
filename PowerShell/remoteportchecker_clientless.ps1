#This is Non Telnet method to check open ports
$ipaddress = "127.0.0.1"
$port = 5601
$connection = New-Object System.Net.Sockets.TcpClient($ipaddress, $port)

if ($connection.Connected) {
    Write-Host "Success"
}
else {
    Write-Host "Failed"
}