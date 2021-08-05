Set objNetwork = CreateObject("Wscript.Network")
'Set objSysInfo = CreateObject("ADSystemInfo")

' Display DN of local computer.
Wscript.Echo objSysInfo.ComputerName

' Display DNS Name of domain.
'Wscript.Echo objSysInfo.DomainDNSDomain

' Display DNS name of local computer.
Wscript.Echo objNetwork.ComputerName 
    '& "." & objSysInfo.DomainDNSDomain