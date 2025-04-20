[CmdletBinding()]
param
(
    [parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$GraphToken,
    [parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$folder
)

$headers = @{
    "Content-Type" = "application/json"
    Authorization = "Bearer {0}" -f $GraphToken
}

$policyfiles = Get-ChildItem $folder | Select-Object -ExpandProperty Name

Foreach ($policyfile in $policyfiles) {

    Try {
        $policy = Get-Content -path $folder\$policyfile
        $policyCheck = (Invoke-webrequest -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies" -Method GET -Headers $headers).value

        if ($policyCheck.Name -gt 0){
        Write-Host "$($policyCheck.Name) already exists, patching profile"
        Invoke-webrequest -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies" -Method PATCH -Headers $headers -Body $policy
        }
        if (!$policyCheck.Name -lt 1){
            Write-Host "$($policyCheck.Name) does not exist, creating new profile"
            Invoke-webrequest -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies" -Method POST -Headers $headers -Body $policy
        }
    }
    Catch {
        Write-Host "there was an error importing $policyfile"
        Write-Host $_
    }
}

