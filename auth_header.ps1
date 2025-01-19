# Parameters
$ApiEndpoint = "https://3l2zlqtv94.execute-api.us-east-2.amazonaws.com/gtg"
$HttpMethod = "GET" # Change this to POST, PUT, DELETE, etc., if needed
$Region = "us-east-2" # AWS region
$Service = "execute-api" # AWS service

# Get AWS credentials from the CLI
$AwsAccessKey = aws configure get aws_access_key_id
$AwsSecretKey = aws configure get aws_secret_access_key
$AwsSessionToken = aws configure get aws_session_token # For temporary credentials

# Validate credentials
if (-not $AwsAccessKey -or -not $AwsSecretKey) {
    Write-Error "AWS credentials not found. Configure them using 'aws configure'."
    exit
}

# Get the current date in required formats
$AmzDate = (Get-Date -UFormat "%Y%m%dT%H%M%SZ") # e.g., 20250119T123456Z
$DateStamp = (Get-Date -UFormat "%Y%m%d") # e.g., 20250119

# Extract the host and path from the API endpoint
$Uri = [System.Uri]$ApiEndpoint
$HostPart = $Uri.Host
$CanonicalUri = $Uri.AbsolutePath

# Canonical headers and signed headers
$CanonicalHeaders = "host:$HostPart`nx-amz-date:$AmzDate`n"
$SignedHeaders = "host;x-amz-date"

# Payload hash
$Sha256 = [System.Security.Cryptography.SHA256]::Create()
$PayloadHash = [System.BitConverter]::ToString($Sha256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes(""))).Replace("-", "").ToLower()

# Canonical request
$CanonicalRequest = "$HttpMethod`n$CanonicalUri`n`n$CanonicalHeaders`n$SignedHeaders`n$PayloadHash"

# String to sign
$Algorithm = "AWS4-HMAC-SHA256"
$CredentialScope = "$DateStamp/$Region/$Service/aws4_request"
$CanonicalRequestHash = [System.BitConverter]::ToString($Sha256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($CanonicalRequest))).Replace("-", "").ToLower()
$StringToSign = "$Algorithm`n$AmzDate`n$CredentialScope`n$CanonicalRequestHash"

# Generate the signing key
function Get-HmacSHA256 ([byte[]]$Key, [string]$Data) {
    $Hmac = New-Object System.Security.Cryptography.HMACSHA256
    $Hmac.Key = $Key
    $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Data)
    return $Hmac.ComputeHash($Bytes)
}

$DateKey = Get-HmacSHA256 ([System.Text.Encoding]::UTF8.GetBytes("AWS4" + $AwsSecretKey)) $DateStamp
$RegionKey = Get-HmacSHA256 $DateKey $Region
$ServiceKey = Get-HmacSHA256 $RegionKey $Service
$SigningKey = Get-HmacSHA256 $ServiceKey "aws4_request"

# Calculate the signature
$Hmac = New-Object System.Security.Cryptography.HMACSHA256
$Hmac.Key = $SigningKey
$Signature = [System.BitConverter]::ToString($Hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($StringToSign))).Replace("-", "").ToLower()

# Generate the Authorization header
$AuthorizationHeader = "$Algorithm Credential=$AwsAccessKey/$CredentialScope, SignedHeaders=$SignedHeaders, Signature=$Signature"

# Add optional session token header if present
$Headers = @{
    "Authorization" = $AuthorizationHeader
    "x-amz-date"    = $AmzDate
}
if ($AwsSessionToken) {
    $Headers["x-amz-security-token"] = $AwsSessionToken
}

Write-Output "Canonical Request:"
Write-Output $CanonicalRequest

Write-Output "String to Sign:"
Write-Output $StringToSign

Write-Output "Authorization Header:"
Write-Output $AuthorizationHeader

Write-Output "Headers Sent to API Gateway:"
$Headers.GetEnumerator() | ForEach-Object { Write-Output "$($_.Key): $($_.Value)" }

# # Make the HTTP request
# Write-Output "Calling API Gateway endpoint..."
# $response = Invoke-RestMethod -Uri $ApiEndpoint -Method $HttpMethod -Headers $Headers

# # Print the response
# Write-Output "Response from API Gateway:"
# $response | ConvertTo-Json -Depth 10