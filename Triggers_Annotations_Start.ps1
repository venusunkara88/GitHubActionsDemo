# $env:SynapseWorkspace = "testtriggerautomate"
# $env:ResourceGroup = "RG-Metrolinx"
# $Annotations = "LDS"
# Input parameters
# param(
#     [string]$Action = "start",
#     [string]$NameFilter = "",
#     [switch]$WhatIf
# )
$env:SynapseWorkspace
$env:ResourceGroup
$Annotations = "LDS"
$NameFilter = ""

Write-Output ("Getting workspace {0} in resource group {1}" -f "$env:SynapseWorkspace", "$env:ResourceGroup")
$workspace = Get-AzSynapseWorkspace -ResourceGroupName "$env:ResourceGroup" -Name "$env:SynapseWorkspace"
if (-not($workspace)) { throw "Could not find workspace" }
Write-Output $workspace


$triggers = Get-AzSynapseTrigger -WorkspaceObject $workspace
$stoppedTriggers = $Triggers | Where-Object { $_.Properties.RuntimeState -eq "Stopped" }
$startedTriggers = @()
if ($namefilter -ne '-') { $triggers = $triggers | Where-Object { $_.Name -match $namefilter } }
Write-Output ("Found {0} triggers" -f $triggers.Count)
if (-not($triggers)) { exit }


foreach ($trigger in $Triggers) {
 if(($Trigger.Properties.Annotations[0] -eq $Annotations) -and ($Trigger.Properties.RuntimeState -eq "Stopped"))
    {
#Start-AzSynapseTrigger -WorkspaceName "$env:SynapseWorkspace" -Name $trigger.Name -WhatIf:$WhatIf.IsPresent -PassThru
$startedTriggers += $trigger.Name
foreach ($triggerName in $startedTriggers) {
    Start-AzSynapseTrigger -WorkspaceName "$env:SynapseWorkspace" -Name $trigger.Name -WhatIf:$WhatIf.IsPresent -PassThru
    Write-Host "Started trigger $triggerName."
}
}
}
