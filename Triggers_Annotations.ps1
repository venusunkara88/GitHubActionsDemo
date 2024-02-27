# Input parameters
param(
    [string]$Action = "start",
    [string]$NameFilter = "",
    [switch]$WhatIf
)
$env:SynapseWorkspace
$env:ResourceGroup
$Annotations = "LDS"

# Get the specified workspace
Write-Output ("Getting workspace {0} in resource group {1}" -f "$env:SynapseWorkspace", "$env:ResourceGroup")
$workspace = Get-AzSynapseWorkspace -ResourceGroupName "$env:ResourceGroup" -Name "$env:SynapseWorkspace"
if (-not($workspace)) { throw "Could not find workspace" }
Write-Output $workspace


# Get the list of triggers if the workspace 
Write-Output "Getting triggers"
$triggers = Get-AzSynapseTrigger -WorkspaceObject $workspace
$stoppedTriggers = $Triggers | Where-Object { $_.Properties.RuntimeState -eq "Stopped" }
$startedTriggers = @()
if ($namefilter -ne '-') { $triggers = $triggers | Where-Object { $_.Name -match $namefilter } } # filter out names if the filter is specified
Write-Output ("Found {0} triggers" -f $triggers.Count)
if (-not($triggers)) { exit }

foreach ($trigger in $Triggers) {
 if(($Trigger.Properties.Annotations[0] -eq $Annotations) -and ($Trigger.Properties.RuntimeState -eq "Started"))
    {
# Stop the Triggers that were in "Started" state
Stop-AzSynapseTrigger -WorkspaceName "$env:SynapseWorkspace" -Name $t.name -WhatIf:$WhatIf.IsPresent -PassThru
$startedTriggers += $trigger.Name
Write-Host "Stopped trigger $($trigger.Name)."
} elseif ($trigger.Triggerstate -eq "Stopped") {
    Write-Host "Trigger $($trigger.Name) is already in a stopped state."
} else {
    Write-Host "Trigger $($trigger.Name) is in an unknown state: $($trigger.Triggerstate)."
}
}


# Start the Triggers that were in "Started" state before stopping
foreach ($triggerName in $startedTriggers) {
    Start-AzSynapseTrigger -WorkspaceName "$env:SynapseWorkspace" -Name $t.name -WhatIf:$WhatIf.IsPresent -PassThru
    Write-Host "Started trigger $triggerName."
}