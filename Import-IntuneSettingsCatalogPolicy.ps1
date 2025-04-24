[CmdletBinding()]
param
(
    [parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$folder
)

$policyfiles = Get-ChildItem $folder | Select-Object Name, BaseName

Foreach ($policyfile in $policyfiles){
    $policyName = $policyfile.Name
    $policybaseName = $policyfile.BaseName
    $policy = Get-Content -Path "$folder\$policyName"
    $policyCheck = @()
    $uri = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies"
    
    do {
        $response = Invoke-MgGraphRequest -Uri $uri -Method GET
        $policyCheck += $response.value

        #pagination
        $uri = $response.'@odata.nextLink'
    } while ($uri)

    $existingPolicy = $policyCheck | Where-Object { $_.Name -eq $policyBaseName }

    if ($existingPolicy){
        Write-Host "$($existingPolicy.Name) already exists, modifying profile with PUT"
        Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies/$($existingPolicy.Id)" -Method PUT -Body $policy -ContentType "application/json"
    }
    else{
        Write-Host "$policybaseName does not exist, creating new profile"
        Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies" -Method POST -Body $policy -ContentType "application/json"
    }
}
