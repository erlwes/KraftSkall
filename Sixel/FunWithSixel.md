### Display a users photo from AD in the console

```PowerShell
$bytes = (Get-ADUser morty -Properties thumbnailPhoto).thumbnailPhoto
$MemoryStream = New-Object System.IO.MemoryStream -ArgumentList (,$bytes)
[void]$MemoryStream.Seek(0, [System.IO.SeekOrigin]::Begin)
$MemoryStream | ConvertTo-Sixel
```
