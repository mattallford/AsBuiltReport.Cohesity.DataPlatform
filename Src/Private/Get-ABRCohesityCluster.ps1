function Get-AbrCohesityCluster {
    <#
    .SYNOPSIS
    Used by As Built Report to retrieve information about a Cohesity Cluster from the REST API

    .DESCRIPTION
    This function is used to query the REST API of a Cohesity cluster and return information about the cluster summary
    This function relies on authentication to the Cohesity Platform to have already occurred and the apiAccessToken to be passed in as a parameter

    .EXAMPLE
    Get-ABRCohesityCluster -BaseURL https://cohesity.domain.com/irisservices/api/v1/public -apiAccessToken $accessToken

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
        [String] $apiAccessToken
    )
    
    begin {
        $Header = @{'accept' = 'application/json'; 
            'content-type' = 'application/json'; 
            'authorization' = "Bearer" + ' ' + $apiAccessToken}
        $URI = "$BaseURL/cluster"
    }
    
    process {
        try {
            $CohesityCluster = Invoke-RestMethod -Method Get -Uri $URI -header $header
        } catch {

        }

        if ($CohesityCluster) {
            Paragraph "The following section provides a summary of the Cohesity Cluster"
            BlankLine
            $CohesityClusterConfig = [PSCustomObject] @{
                'Cluster ID' = $CohesityCluster.id
                'Cluster Name' = $CohesityCluster.name
                'Node #' = $CohesityCluster.nodeCount
                'Software Version' = $CohesityCluster.clusterSoftwareVersion
                'Encryption Enabled' = $CohesityCluster.encryptionEnabled
                'Cluster Type' = $CohesityCluster.clusterType
                'Storage Capacity for Metadata (GB)' = (Convert-Size -From B -To GB $CohesityCluster.availableMetadataSpace)
                'Storage Used for Metadata %' = [math]::Round($CohesityCluster.usedMetadataSpacePct,2)
                'DNS Servers' = $CohesityCluster.dnsServerIps -join ', '
                'Domain Name(s)' = $CohesityCluster.domainNames -join ', '
                'Support Channel Enabled' = $CohesityCluster.reverseTunnelEnabled
                'Timezone' = $CohesityCluster.Timezone
            }

            $TableParams = @{
                Name = "Cluster Configuration"
                List = $true
                ColumnWidths = 50, 50
            }
            if ($ShowTableCaptions) {
                $TableParams['Caption'] = "- $($TableParams.Name)"
            }

            $CohesityClusterConfig | Table @TableParams
        }
    }
}