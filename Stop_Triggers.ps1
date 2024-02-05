# Input parameters
param(
    [string]$Action = "stop",
    [string]$NameFilter = "",
    [switch]$WhatIf
)
$env:SynapseWorkspace
$env:ResourceGroup

# Get the specified workspace
Write-Output ("Getting workspace {0} in resource group {1}" -f "$env:SynapseWorkspace", "$env:ResourceGroup")
$workspace = Get-AzSynapseWorkspace -ResourceGroupName "$env:ResourceGroup" -Name "$env:SynapseWorkspace"
if (-not($workspace)) { throw "Could not find workspace" }
Write-Output $workspace


# Get the list of triggers if the workspace 
Write-Output "Getting triggers"
$triggers = Get-AzSynapseTrigger -WorkspaceObject $workspace
if ($namefilter -ne '-') { $triggers = $triggers | Where-Object { $_.Name -match $namefilter } } # filter out names if the filter is specified
Write-Output ("Found {0} triggers" -f $triggers.Count)
if (-not($triggers)) { exit }

# Continue only if there are triggers to be found
if ($triggers.Count -gt 0) {
    if ($action -eq "stop") {
        # Stop the triggers
        Write-Output "Looping through triggers that are started ..."
        $startedtriggers = $triggers | Where-Object { $_.Properties.RuntimeState -eq "Started" }
        Write-Output ("Found {0} started triggers" -f $startedtriggers.Count)

        foreach ($t in $startedtriggers) {
            Write-Output ("Stopping {0} ..." -f $t.Name);
            try {
                $result = Stop-AzSynapseTrigger -WorkspaceName "$env:SynapseWorkspace" -Name $t.name -WhatIf:$WhatIf.IsPresent -PassThru 
                Write-Output ("Result of stopping trigger {0}: {1}" -f $t.Name, $result)
            }
            catch {
                Write-Output ("Something went wrong with {0}" -f $t.Name)
                Write-Output $_
            }
        }
    }
    Write-Output "... done"
}
