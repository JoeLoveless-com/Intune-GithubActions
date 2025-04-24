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

        $policy = Get-Content -path $folder\$policyName
        $policyCheck = (Invoke-Mggraphrequest -uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies" -Method GET).value | Where-Object { $_.Name -eq $policyBaseName }

        if ($policyCheck.Name){
        Write-Host "$($policyCheck.Name) already exists, modifying profile with PUT"
        Invoke-Mggraphrequest -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies/$($policyCheck.Id)" -Method PUT -Body $policy -ContentType "application/json"
        }
        if (!$policyCheck.Name){
            Write-Host "$($policyCheck.Name) does not exist, creating new profile"
            Invoke-Mggraphrequest -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies" -Method POST -Body $policy -ContentType "applilcation/json"
    }
}
