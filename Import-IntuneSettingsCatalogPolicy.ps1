<#
.SYNOPSIS
Creates (or updates if exist) device health scripts in Intune.
.DESCRIPTION
This script searches in a provided folder for subfolders where the scripts are in. 
The script name is the name of the folder where the script set is in. In the script set folder there must be a detection_xx.ps1 and remediate_xx.ps1
.PARAMETER GraphToken
Enter the Graph Bearer token
.PARAMETER ScriptsFolder
Provide the path where the scripts folders are.
.EXAMPLE
.\manage-devicehealthscripts.ps1 -GraphToken xxxx -ScriptsFolder .\AllDetectionScripts
#>
[CmdletBinding()]
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$GraphToken,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Folder
    )

    $headers = @{
        "Content-Type" = "application/json"
        Authorization = "Bearer {0}" -f $GraphToken
    }

    $apiUrl = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies"
    $method = "POST"

try {
    $folders = Get-ChildItem -Path $folder -Directory

    foreach ($folder in $folders) {
        try {

            $json = Get-ChildItem -Path $folder.FullName -File -Filter "*.json" | Select-Object -First 1
            if ($json) {
                Write-Host "File found: $($json.FullName)"

            } else {
                Write-Error "No policy found."
            }
            $jsonConvert = $json | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version, supportsScopeTags
            $jsonOutput = $jsonConvert | ConvertTo-Json -Depth 20

            Try{
            Invoke-webrequest -Uri $apiUrl -Method $Method -Headers $headers -Body $body
            Write-Output "Adding Settings Catalog Policy '$DisplayName'"

            }
            Catch{
                Write-Error "Error adding policy : $_"
            }
        }
        catch {
            Write-Error "Not able to create policy with name $($folder.name), $_"
        }
    }
}
catch {
    Write-Error "Not able to run succesfully, $_"
}