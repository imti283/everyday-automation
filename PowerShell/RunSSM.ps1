Import-Module AWSPowerShell
Set-DefaultAWSRegion us-east-1

$DateTime = Get-Date

###                  
###                  +-++-++-++-+ +-++-++-++-++-++-+ +-++-++-++-++-++-+ +-++-++-++-+
###                  |M||u||s||t| |C||h||a||n||g||e| |V||a||l||u||e||s| |h||e||r||e|
###                  +-++-++-++-+ +-++-++-++-++-++-+ +-++-++-++-++-++-+ +-++-++-++-+
###                  
            $Scriptpath = "<DirectoryPath>"
            $ScriptName = Read-Host 'Please enter File to be run - '
            $tagName = '<Ec2Tag>'
            $tagValue = Read-Host 'Please enter AutoScaling Group Name - '
###      
###                  +-++-++-++-++-++-++-+ +-++-++-++-++-+ +-++-++-++-++-++-+
###                  |P||r||o||c||e||e||d| |A||f||t||e||r| |C||h||a||n||g||e|
###                  +-++-++-++-++-++-++-+ +-++-++-++-++-+ +-++-++-++-++-++-+
###   

$Commands = Get-Content -Path "$Scriptpath\$ScriptName" -Raw
$Instances = (Get-EC2Tag -Filter @{Name = "tag:$tagName"; Value = "$tagValue" } -ProfileName DevOpsUser).ResourceId
if([string]::IsNullOrEmpty($Instances)) {
    $Instances = Read-Host 'Autoscaling group not found.....Please enter Comma Separated InstanceIDs - '
    $InstanceArray = $Instances.split(",")
}
foreach ($Droplet in $InstanceArray) {
    $Comment = "Running cmd from machine - $env:COMPUTERNAME at $DateTime"
    $CommandId = (Send-SSMCommand -DocumentName "AWS-RunPowerShellScript" -ProfileName DevOpsUser -InstanceId "$Droplet" -Comment "$Comment" -Parameter @{'commands' = "$Commands" }).CommandId
    Write-Output "   SendSSM has ran with CommandID - $CommandId"
    $Count = 0
    while ($Count -lt 10) {
        $Command = Get-SSMCommandInvocationDetail -CommandId "$CommandId" -InstanceId "$Droplet" -ProfileName DevOpsUser
        Write-Output "   Waiting for installation..."
        $Count += 1
        if ($Command.ResponseCode -eq -1) {
            Start-Sleep 5
        }
        elseif ($Command.StandardErrorContent -ne "") {
            Write-Output "  Server $Droplet dint executed all sendSSM command successfully. It has below error "
            $Command.StandardErrorContent
        }
        elseif ($Command.Status -eq "Failed") {
            Write-Output "###   FAILED UPDATING SERVER: $InstanceName ($Droplet)  ###"
        }
        elseif ($Command.Status -eq "Success" -and $Command.StandardErrorContent -eq "") {
            Write-Output "###   SUCCESSFULLY UPDATED SERVER: $InstanceName ($Droplet)  ###"
            $Command.StandardOutputContent
            break
        }
    }
}


