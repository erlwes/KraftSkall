
How to figure out what domains, url, fqdn that needs to be allowed for a web-page or application.

## For webpages - use built in developer tools

### In your browser - collect HAR-file
1. Open browser
2. Open developer tools (Ctrl+Shift+I)
3. Go to network tab (clear if a lot of history)
4. Load/browse the wanted web-page
5. Download a HAR-file of traced network traffic

### In PowerShell - get unique domains, grouped
```PwSh
$har = 'learn.microsoft.com.har'
$urls = (Get-Content $env:USERPROFILE\downloads\$har | ConvertFrom-Json).log.entries.request.url
$urls | Foreach-Object {$_.split('/')[2]} | Group-Object -NoElement | Sort-Object Count -Descending
```

### The output
<img width="1145" height="289" alt="image" src="https://github.com/user-attachments/assets/72cc4883-849f-4bef-8f10-439257d89705" />


## For applications - check dns cache and netstat

If we dont want to install Fiddler, BURP or Wireshark, we can ...


### Check DNS Cache
```Pwsh
Clear-DnsClientCache
# Run the application
Get-DnsClientCache
# Se what domains that where resolved
```

### Monitor TCP-connections for a given process (netstat -ano)
```PwSh
$processName = 'msedge'
$Connections = $null
While ($true) {
    $processIds = (Get-Process $processName).Id
    $Connections = Get-NetTCPConnection -OwningProcess $processIds -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1    
    if ($Connections) {
        $Connections
    }
    else {
        'Nothing at the moment'
    }    
}
```

## What about hardcoded IP-adresses?
!_Given that the communication was recently established_!

One should be able to diff ARP-table vs. DNS-client cache.
If the computer communicates with IPs that are not in DNS-cache, but is present in ARP

it _could_ mean that this is a hardcoded value in config file, ODBC or elsewhere 🤷🏻‍♂️
