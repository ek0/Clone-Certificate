param([Parameter(Mandatory=$true)] [String]$FilePath)

# Get a X590Certificate2 certificate object for a file
$cert = (Get-AuthenticodeSignature -FilePath $FilePath).SignerCertificate
if(!$cert)
{
    Write-Host -ForegroundColor Red "No signing certificate"
    return
}
# Create a new chain to store the certificate chain
$chain = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Chain
# Build the certificate chain from the file certificate
$chain.Build($cert)
# Return the list of certificates in the chain (the root will be the last one)
return $chain.ChainElements