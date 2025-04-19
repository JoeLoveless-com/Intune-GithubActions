Function Import-IntuneSettingsCatalogPolicy {
    <#
    .SYNOPSIS
    Import .JSON of a settings catalog policy to Intune.
    .DESCRIPTION
    Import .JSON of a settings catalog policy to Intune. No assignments will be created.
    .EXAMPLE
    Import-IntuneSettingsCatalogPolicy
    .NOTES
    https://github.com/microsoftgraph/powershell-intune-samples/blob/master/SettingsCatalog/SettingsCatalog_Import_FromJSON.ps1
    #>

    [CmdletBinding()]
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Folder
    )

    $GraphTokenResponse = az account get-access-token --resource https://graph.microsoft.com
    $GraphToken = ($GraphTokenResponse | ConvertFrom-Json).accessToken

    $Uri = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies"
    $headers = @{
        "Content-Type" = "application/json"
        Authorization  = "Bearer {0}" -f $GraphToken
    }

    #Declarations
    $date = Get-Date -Format yyyyMMdd-HHmm
    $logfile = "$Outputdir\Import-IntuneSettingsCatalogPolicy-$date.log"

    #region Get Json files
    try {
        $jsonFiles = Get-ChildItem -Path $folder -filter *.json
        Write-Output "Gathering JSON files from $folder"
    }
    Catch {
        Write-Error "Unable to find JSON files in $folder"
        break
    }

    if ($jsonFiles) {
        Write-Output "JSON Files found: $jsonFiles.Name"
    }
    if (!$jsonFiles) {
        Write-Error "No JSON Files found"
        Stop
    }
    #endRegion

    Foreach ($item in $jsonFiles) {
        Try {
            Invoke-webrequest -Uri $Uri -Method POST -Headers $headers -Body $item
        }
        Catch {
            $ex = $_.Exception
            $errorResponse = $ex.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorResponse)
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $responseBody = $reader.ReadToEnd();
            Write-Host "Response content:`n$responseBody" -f Red
            Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
            write-host
            break

        }
    }
}
            
