
#This will clear PowerShell-history
```PwSh
Clear-History
Remove-Item (Get-PSReadLineOption).HistorySavePath
[Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory()
```

If you have scriptblock-logging and/or transcripts configured, your stuff can still be saved somewhere else :)
