# Input parameters
param(
    [string]$SynapseWorkspace = "testtriggerautomate",
    [string]$ResourceGroup = "RG-Metrolinx",
    [string]$Action = "stop",
    [string]$SubscriptionName = "YASH-Azure-DevOps-DataOps-MPN",
    [string]$NameFilter = "",
    [switch]$WhatIf
)


# Get the specified workspace
Write-Output ("Getting workspace {0} in resource group {1}" -f $synapseworkspace, $resourcegroup)
Set-AzContext -Subscription "$SubscriptionName"
$workspace = Get-AzSynapseWorkspace -ResourceGroupName $resourcegroup -Name $synapseworkspace
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
        # Stop triggers
        Write-Output "Looping through triggers that are started ..."
        $startedtriggers = $triggers | Where-Object { $_.Properties.RuntimeState -eq "Stopped" }
        Write-Output ("Found {0} stopped triggers" -f $startedtriggers.Count)

        foreach ($t in $stoppedtriggers) {
            Write-Output ("Stoping {0} ..." -f $t.Name);
            try {
                $result = Stop-AzSynapseTrigger -WorkspaceName $synapseworkspace -Name $t.name -WhatIf:$WhatIf.IsPresent -PassThru
                Write-Output ("Result of starting trigger {0}: {1}" -f $t.Name, $result)
            }
            catch {
                Write-Output ("Something went wrong with {0}" -f $t.Name)
                Write-Output $_
            }
        }
    }

    Write-Output "... done"
}