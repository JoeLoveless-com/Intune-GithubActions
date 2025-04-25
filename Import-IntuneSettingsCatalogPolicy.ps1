[CmdletBinding()]
param
(
    [parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$folder
)

# Fetch all existing policies just once
$policyCheck = @()
$uri = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies"
do {
    $response = Invoke-MgGraphRequest -Uri $uri -Method GET
    $policyCheck += $response.value

    # Pagination handling
    $uri = $response.'@odata.nextLink'
} while ($uri)

# Output all existing policies once
Write-Host "Existing Policies Found:"
$policyCheck | ForEach-Object { Write-Host $_.Name }

$policyfiles = Get-ChildItem $folder | Select-Object Name, BaseName

# Loop through policy files
Foreach ($policyfile in $policyfiles){
    $policyName = $policyfile.Name
    $policybaseName = $policyfile.BaseName

    $policy = Get-Content -Path "$folder\$policyName" -Raw

    # Check if the policy already exists
    $existingPolicy = $policyCheck | Where-Object { $_.Name -ieq $policybaseName }

    if ($existingPolicy){
        Write-Host "$($existingPolicy.Name) already exists, modifying profile with PUT"
        Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies/$($existingPolicy.Id)" -Method PUT -Body $policy -ContentType "application/json"
    }
    else{
        Write-Host "$policybaseName does not exist, creating new profile"
        Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies" -Method POST -Body $policy -ContentType "application/json"
    }
}
