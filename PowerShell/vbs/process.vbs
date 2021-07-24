dim service, Process,LyncVersion
 
set service = GetObject ("winmgmts:")
 
for each Process in Service.InstancesOf ("Win32_Process")
LyncVersion = Process.Name
  if LyncVersion = "lync.exe" then
	LyncVersion = "" & left(Right(Process.ExecutablePath, 11),2) & ".0"
	wscript.echo  LyncVersion
	exit for
	 
  end if
next