[CmdletBinding()]
param
(
    [parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$folder
)

$policyfiles = Get-ChildItem $folder | Select-Object -ExpandProperty Name

Foreach ($policyfile in $policyfiles){
    try{
        $policy = Get-Content -path $folder\$policyfile
        $policyCheck = (Invoke-Mggraphrequest -uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies" -Method GET).value

        if ($policyCheck.Name -gt 0){
        Write-Host "$($policyCheck.Name) already exists, patching profile"
        Invoke-Mggraphrequest -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies" -Method PATCH -Body $policy
        }
        if (!$policyCheck.Name -lt 1){
            Write-Host "$($policyCheck.Name) does not exist, creating new profile"
            Invoke-Mggraphrequest -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies" -Method POST -Body $policy
        }
}
Catch{
    Write-Error "Error: $_"
}
}
