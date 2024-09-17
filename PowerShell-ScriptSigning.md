# Signing scripts with self-signed a certificate
Example script for creating a self signed certificate for code-signing. The new cert defaults to 1-year validity period.

```PowerShell
# CHANGE ME
$Subject = 'myCodeSigningCertificate'
$Domain = 'myDomain.com'

# CREATES A NEW CERTIFICATE TO USERS PERSONAL STORE, WITH PRIVATE KEY    (for signing)
New-SelfSignedCertificate `
    -KeyUsage DigitalSignature `
    -KeySpec Signature `
    -KeyAlgorithm RSA `
    -KeyLength 4096 `
    -DNSName $Domain `
    -CertStoreLocation 'Cert:\CurrentUser\My' `
    -Type CodeSigningCert `
    -Subject $Subject

# GET THE NEW CERT FROM CERTIFICATE STORE
$Cert = Get-ChildItem Cert:\CurrentUser\My\ | Where-Object {$_.Subject -match $Subject}

# EXPORT THE CERTIFICATE TO FILE    (only public key is exported)
Export-Certificate -Cert $Cert -FilePath .\$Subject.cer -Force

# IMPORT THE CERT WITH PUBLIC KEY TO USERS TRUSTED PUBLISHERS   (for validation)
Import-Certificate -CertStoreLocation Cert:\CurrentUser\Root -FilePath .\$Subject.cer               #Cert need to be in this certificate store to validate cert-chain when signing scripts
Import-Certificate -CertStoreLocation Cert:\CurrentUser\TrustedPublisher -FilePath .\$Subject.cer   #Cert need to be in this certificate store run without warnings

# SIGN A SCRIPT WITH PRIVATE KEY    (this fails if the cert is not imported to trusted root cert store)
Set-AuthenticodeSignature .\script.ps1 -Certificate $Cert

# TEST    (notice a signature has been appended to the script content)
Set-ExecutionPolicy AllSigned
& .\script.ps1
```

### Warning when running script?
If the certs used for signing the script is not present in trusted publishers, you will get this warning:
```
Do you want to run software from this untrusted publisher?
File C:\Temp\script.ps1 is published by CN=myCodeSigningCertificate and is not trusted on your system. Only run scripts from trusted publishers.
[V] Never run  [D] Do not run  [R] Run once  [A] Always run  [?] Help (default is "D"):
```
If you choose [A] - Always run, then script will be imported into the users "Trusted Publishers" certificate store, and the warning will thefore not show the next time

### Make changes to script?
Whenever there are changes in the script, the hash of the file will not longer match the hash stored in the digital signature, and you will get this error:
```
.\script.ps1: File C:\Temp\script.ps1 cannot be loaded.
The contents of file C:\Temp\script.ps1 might have been changed by an unauthorized user or process, because the hash of the file does not match the hash stored in the digital signature.
The script cannot run on the specified system. For more information, run Get-Help about_Signing..
```

The script will need to be signed again.
You don't need to remove previous signature from script, PowerShell will figure it out and replace the old signature.
The signature has to be at the end of the script. You can not move it, and then sign it again to account for new hash (I tried, and it failed).
