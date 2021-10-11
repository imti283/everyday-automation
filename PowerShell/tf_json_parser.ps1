$val = terragrunt run-all show -json plan.out
$Style = @"
<style>
BODY{font-family:Calibri;font-size:12pt;}
TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse; padding-right:5px}
TH{border-width: 1px;padding: 5px;border-style: solid;border-color: black;color:black;background-color:#FFFFFF }
TH{border-width: 1px;padding: 5px;border-style: solid;border-color: black;background-color:Green}

</style>
"@

$returnObj = @()
$strhtml = ""
if ($val.count -gt 1) {
    foreach ($v in $val.GetEnumerator()) { 
        $curr = $v | ConvertFrom-Json
        foreach ($rc in $curr.resource_changes) { 
            $obj = New-Object psobject -Property @{`
                    "Project"  = $curr.variables.application_op.value;
                "Action"       = switch ($($rc.change.actions)) {
                    "create" { '<font color="green">create</font>' }
                    "no-op" { '<font color="grey">no-op</font>' }
                    "read" { '<font color="blue">read</font>' }
                    "update" { '<font color="yellow">update</font>' }
                    "replace" { '<font color="red">replace</font>' }
                    "delete" { '<font color="red">delete</font>' }
                };
                "ResourceType" = $rc.type;
                "Adress"       = $rc.address
            }
            $returnObj += $obj
        }
    }
}
elseif ($val.count -eq 1) {
    $curr = $val | ConvertFrom-Json
    foreach ($rc in $curr.resource_changes) { 
        $obj = New-Object psobject -Property @{`
                "Project"  = $curr.variables.application_op.value;
            "Action"       = switch ($($rc.change.actions)) {
                "create" { '<font color="green">create</font>' }
                "no-op" { '<font color="grey">no-op</font>' }
                "read" { '<font color="blue">read</font>' }
                "update" { '<font color="yellow">update</font>' }
                "replace" { '<font color="red">replace</font>' }
                "delete" { '<font color="red">delete</font>' }
            };
            "ResourceType" = $rc.type;
            "Adress"       = $rc.address
        }
        $returnObj += $obj
    }
}
else {
$strhtml =  "No change found"
}


if ($val.count -ge 1) {

    $returnObj | Select Project, Action, Adress, ResourceType

    $newtab = $returnObj | ? { $_.Action -notmatch "no-op" } | Select Project, Action, Adress, ResourceType

    $strhtml = $newtab | ConvertTo-Html -Head $Style
    $strhtml = [System.Net.WebUtility]::HtmlDecode($strhtml) 

    Send-MailMessage -Body $strhtml -BodyAsHtml $true -SmtpServer 'xxxx' -Port 25
}
else {
    Send-MailMessage -Body $strhtml  -SmtpServer 'xxxx' -Port 25
}
