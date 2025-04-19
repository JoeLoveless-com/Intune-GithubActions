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

    $GraphTokenResponse = az account get-access-token --resource https://graph.microsoft.com
$GraphToken = ($GraphTokenResponse | ConvertFrom-Json).accessToken

try {
    $folders = Get-ChildItem -Path $folder -Directory
    $headers = @{
        "Content-Type" = "application/json"
        Authorization = "Bearer {0}" -f $GraphToken
    }
    $apiUrl = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies"
    $method = "POST"

    foreach ($folder in $folders) {
        try {
            $policy = Invoke-webrequest -Uri $apiUrl -Method GET -Headers $headers
            $policyCheck = ($policy.content | Convertfrom-json).value | Where-Object {$_.displayName -eq $folder.Name}

            $jsonFile = Get-ChildItem -Path $folder.FullName -File -Filter "*.Json"
            if ($jsonFile) {
                Write-Host "File found: $($jsonFile.Name)"
                $jsonContent = get-content $jsonFile
                $jsonConvert = $jsonContent | ConvertFrom-Json
                $DisplayName = $jsonConvert.name
                $jsonOutput = $jsonConvert | ConvertTo-Json -depth 20
            } else {
                Write-Host "No Settings Catalog file found."
            }

            Write-Host "Settings Catalog Policy '$DisplayName' Found..."
            $jsonOutput
            Write-Host "Adding Settings Catalog Policy '$DisplayName'"
            Try{
            Invoke-webrequest -Uri $apiUrl -Method $Method -Headers $headers -Body $jsonOutput
            }
            Catch{
                Write-Host "$_"
            }
        }
        catch {
            Write-Host "Not able to create policy with name $($folder.name), $_"
        }
    }
}
catch {
    Write-Host "Not able to run succesfully, $_"
}