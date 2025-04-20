function Import-IntuneSettingsCatalogPolicy {
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
            Invoke-webrequest -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies" -Method POST -Headers $headers -Body $policy
        }
        Catch {
            Write-Host "there was an error importing $policyfile"
            Write-Host $_
        }
    }
}