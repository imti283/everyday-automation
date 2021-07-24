On error resume next
Dim data
Dim recordCount
Dim regEx
Set regEx = new RegExp
regEx.Pattern = "\r|\n|,|"""

Set con = CreateObject("ADODB.Connection")
con.ConnectionString = "Provider=SQLOLEDB;Integrated Security=SSPI;Persist Security Info=False;Data Source=<Enter Source>;Initial Catalog=Users"
con.Open
strQry = "SELECT * FROM settings (NOLOCK) WHERE DISABLED='Y'  DisabledDays>89"
set data = con.execute(strQry)

Set filsSysObj = CreateObject("Scripting.FileSystemObject")    
Set csvFile = filsSysObj.OpenTextFile("C:\CSVFile.csv", 8, True)

recordCount = data.Fields.Count      

do until data.EOF
Separator = ""
for i = 0 to data.Fields.Count - 1
Column = data.Fields( i ).Value & ""
if regEx.Test( Column ) then
Column = """" & Replace( Column, """", """""" ) & """"
end if
csvFile.Write Separator & Column
Separator = ","
next
csvFile.Write vbNewLine
data.MoveNext
loop