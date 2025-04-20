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

    Set-PSRepository PSGallery -InstallationPolicy Trusted
    Install-Module "Microsoft.Graph.Authentication"
    Get-Module "Microsoft.Graph.Authentication" -ListAvailable
    Connect-MgGraph -AccessToken $GraphToken

    $policyfiles = Get-ChildItem $folder | Select-Object -ExpandProperty Name

    Foreach ($policyfile in $policyfiles) {

        Try {
            $policy = Get-Content -path $folder\$policyfile
            Invoke-webrequest -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies" -Method POST -Headers $headers -Body $policy -ContentType "application/json"
        }
        Catch {
            Write-Host "there was an error importing $policyfile"
            Write-Host $_
        }
    }
}