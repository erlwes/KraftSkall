### Display a users photo from AD in the console

```PowerShell
$bytes = (Get-ADUser morty -Properties thumbnailPhoto).thumbnailPhoto
$MemoryStream = New-Object System.IO.MemoryStream -ArgumentList (,$bytes)
[void]$MemoryStream.Seek(0, [System.IO.SeekOrigin]::Begin)
$MemoryStream | ConvertTo-Sixel
```

### Get cartoons and display in console
```PowerShell
Invoke-WebRequest -Uri "https://www.tu.no/tegneserier/lunch" | select -ExpandProperty images | ? {$_.OuterHTML -match 'lunch'} | select -ExpandProperty src | % {ConvertTo-Sixel -Url $_}

ConvertTo-Sixel -Url "https://images.squarespace-cdn.com/content/v1/5ec1b690abe5b9359ada2907/0d255ad9-d876-413d-b90f-74a178a822f6/CURIOUS+CREATURE.png?format=500w"
```

### Sixel on server OS
To get Sixel running on Windows server OS, on would first have to install Windows Terminal. Terminal runs fine on server 2022.
