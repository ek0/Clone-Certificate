param([Parameter(Mandatory=$true)] [String]$OriginalFile,
      [Parameter(Mandatory=$true)] [String]$TargetFile)

# Setup Cert Store in Reg
$CertStoreLocation = @{ CertStoreLocation = 'Cert:\CurrentUser\My' }
# Setup Cert Store on Disk
.\Enumerate-Certificates.ps1 $OriginalFile | ForEach-Object { Export-Certificate -Cert $_.Certificate -Type CERT -FilePath $_.Certificate.Thumbprint + ".cer" }
#Get-ChildItem -Path "cert:\CurrentUser\My | ?{$_.Subject -eq "CN=TodoListDaemonWithCert"}
#[system.io.directory]::CreateDirectory(".\CertStore")
# Save each certificate to disk
ForEach-Object { Export-Certificate -Cert $_.Certificate -Type CERT -FilePath $_.Certificate.Thumbprint + ".cer"}
Get-AuthenticodeSignature -FilePath $TargetFile # print results