function Get-AbrCohesityActiveDirectory {
    <#
    .SYNOPSIS
    Used by As Built Report to retrieve Active Directory configuration of a Cohesity Cluster from the REST API

    .DESCRIPTION
    This function is used to query the REST API of a Cohesity cluster and return information about the Active Directory Configuration
    This function relies on authentication to the Cohesity Platform to have already occurred and the apiAccessToken to be passed in as a parameter

    .EXAMPLE
    Get-ABRCohesityActiveDirectory -BaseURL https://cohesity.domain.com/irisservices/api/v1/public -apiAccessToken $accessToken

    .NOTES
        Version:        0.0.1
        Author:         Matt Allford
        Twitter:        @mattallford
        Github:         mattallford

    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.Cohesity.DataPlatform
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String] $BaseURL,

        [Parameter(Mandatory=$true)]
        [String] $apiAccessToken,

        [Parameter(Mandatory=$true)]
        [String] $ShowTableCaptions
    )
    
    begin {
        $Header = @{'accept' = 'application/json'; 
            'content-type' = 'application/json'; 
            'authorization' = "Bearer" + ' ' + $apiAccessToken}
        $URI = "$BaseURL/activeDirectory"
    }
    
    process {
        try {
            $CohesityAD = Invoke-RestMethod -Method Get -Uri $URI -header $header
        } catch {

        }

        if ($CohesityAD) {
            Paragraph "The following section provides a summary of the Cohesity Cluster Active Directory Configuration"
            BlankLine
            $CohesityClusterADConfig = foreach ($AD in $CohesityAD) {
                [PSCustomObject] @{
                    'Domain Name' = $AD.domainName
                    'Machine Accounts' = $AD.machineAccounts -join ", "
                    'Workgroup' = $AD.Workgroup
                    'Trusted Domains Enabled' = $AD.trustedDomainsEnabled
                }
            }

            $TableParams = @{
                Name = "Active Directory Configuration"
                List = $true
                ColumnWidths = 50, 50
            }
            if ($ShowTableCaptions) {
                $TableParams['Caption'] = "- $($TableParams.Name)"
            }
            $CohesityClusterADConfig | Table @TableParams
        }
    }
}