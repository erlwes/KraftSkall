# Convert from filetime to date
```PwSh
[datetime]::FromFileTime("134064252000000000")
```
Example
```PwSh
Get-ADUser rick -Properties * | Select @{Name = 'ExpiresDate'; e={[datetime]::FromFileTime($_.accountExpires)}}
```
