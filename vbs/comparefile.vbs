Const ForReading = 1

Set objFSO = CreateObject("Scripting.FileSystemObject")

Set objFile1 = objFSO.OpenTextFile("<Path>\test1.txt", ForReading)


strCurrentDevices = objFile1.ReadAll

objFile1.Close


Set objFile2 = objFSO.OpenTextFile("<Path>\test2.txt", ForReading)


Do Until objFile2.AtEndOfStream

    strAddress = objFile2.ReadLine

    If InStr(strCurrentDevices, strAddress) = 0 Then

        strNotCurrent = strNotCurrent & strAddress & vbCrLf

    End If

Loop


objFile2.Close


Wscript.Echo "Addresses without current devices: " & vbCrLf & strNotCurrent


Set objFile3 = objFSO.CreateTextFile("<Path>\Differences.txt")


objFile3.WriteLine strNotCurrent

objFile3.Close