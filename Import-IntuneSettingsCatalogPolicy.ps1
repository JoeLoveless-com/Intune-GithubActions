[CmdletBinding()]
param (
    [parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$folder
)

$policyfiles = Get-ChildItem $folder | Select-Object Name, BaseName

foreach ($policyfile in $policyfiles) {
    $policyName = $policyfile.Name
    $policyBaseName = $policyfile.BaseName
    $policyRaw = Get-Content -Path "$folder\$policyName" -Raw

    # Convert to PowerShell object
    $policyObj = $policyRaw | ConvertFrom-Json

    # Remove problematic navigation annotations
    $policyObj.PSObject.Properties.Remove('settingDefinitions@odata.associationLink')

    # Convert back to JSON
    $policyJson = $policyObj | ConvertTo-Json -Depth 10

    $policyCheck = @()
    $uri = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies"

    do {
        $response = Invoke-MgGraphRequest -Uri $uri -Method GET
        $policyCheck += $response.value

        # Pagination
        $uri = $response.'@odata.nextLink'
    } while ($uri)

    $existingPolicy = $policyCheck | Where-Object { $_.Name -eq $policyBaseName }

    if ($existingPolicy) {
        Write-Host "$($existingPolicy.Name) already exists, modifying profile with PUT"
        Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies/$($existingPolicy.Id)" -Method PUT -Body $policyJson -ContentType "application/json"
    } else {
        Write-Host "$policyBaseName does not exist, creating new profile"
        Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies" -Method POST -Body $policyJson -ContentType "application/json"
    }
}
