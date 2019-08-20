function Invoke-AsBuiltReport.Cohesity.DataPlatform {
    <#
    .SYNOPSIS

    .DESCRIPTION

    .NOTES

    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.Cohesity.DataPlatform
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string[]] $Target,

        [Parameter(Mandatory=$true)]
        [pscredential] $Credential,

        [Parameter(Mandatory=$false)]
        [string] $StylePath
    )

    foreach ($CohesityCluster in $Target) {

        # Import JSON Configuration for Options and InfoLevel
        $InfoLevel = $ReportConfig.InfoLevel
        $Options = $ReportConfig.Options

        # If custom style not set, use default style
        if (!$StylePath) {
            & "$PSScriptRoot\..\..\AsBuiltReport.Cohesity.DataPlatform.Style.ps1"
        }

        # Allow the connection to complete if the endpoint has an untrusted certificate
        add-type @"
            using System.Net;
            using System.Security.Cryptography.X509Certificates;
            public class TrustAllCertsPolicy : ICertificatePolicy {
                public bool CheckValidationResult(
                    ServicePoint srvPoint, X509Certificate certificate,
                    WebRequest request, int certificateProblem) {
                    return true;
                }
            }
"@
        [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

        # Ensure TLS12 is added to the Security Protocol
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        # Create the Header, Body and URL for authentication and token retrieval
        $AuthHeader = @{'accept' = 'application/json'; 
                    'content-type' = 'application/json'}

        $AuthBody = ConvertTo-Json @{'domain' = 'local'; 
                                'username' = $($Credential.UserName); 
                                'password' = "$($Credential.GetNetworkCredential().Password)"}
        # Create the BaseURL to the endpoint. This will be used regularly in the rest of the script
        $BaseURL = "https://$CohesityCluster/irisservices/api/v1/public"
        # Create the authentication URL
        $AuthURL = $BaseURL + '/accessTokens'
        # Connect to the endpoint and retrieve authentication information
        $auth = Invoke-RestMethod -Method Post -Uri $AuthURL -Header $AuthHeader -Body $AuthBody
        
        
        Section -Style Heading1 $CohesityCluster {
            if ($CohesityClusterInfo = Get-ABRCohesityCluster -BaseURL $BaseURL -apiAccessToken $auth.accessToken) {
                Section -Style Heading2 'Cluster Summary' {
                    $CohesityClusterInfo
                }
            }

            if ($CohesityADInfo = Get-ABRCohesityActiveDirectory -BaseURL $BaseURL -apiAccessToken $auth.accessToken) {
                Section -Style Heading2 'Active Directory Summary' {
                    $CohesityADInfo
                }
            }
        }

    }
}