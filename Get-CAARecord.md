## Certificate Authority Authorization DNS records

Two different providers that gives CAA DNS Records (Certificate Authority Authorization).
Used to prevent unauthorized certificate issuance, by restricting issuer for the given domain.

CloudFlare.. returns hex-string. Start removed, and splitted into flags, tags and values.
```PowerShell
Function Get-CAARecordCloudFlare {
    param(
        [string]$Domain
    )

    try {
        $Response = Invoke-RestMethod -Uri "https://cloudflare-dns.com/dns-query?name=$Domain&type=CAA" -Headers @{accept = "application/dns-json"} -ErrorAction Stop
        $Records = $Response.Answer | Where-Object { $_.type -eq 257 } |  Select-Object name, TTL, Data
    }
    catch {
        break
    }
    
    foreach ($Rec in $Records) {       
        $HexString = $Rec.Data
        $Hex = ($HexString -split ' ')[2..($HexString.Split(' ').Length - 1)]
        $Bytes = $Hex | ForEach-Object { [Convert]::ToByte($_,16) }

        $Flags = $Bytes[0]
        $TagLen = $Bytes[1]
        $Tag = [System.Text.Encoding]::ASCII.GetString($Bytes[2..(1+$TagLen)])
        $Value = [System.Text.Encoding]::ASCII.GetString($Bytes[(2+$TagLen)..($Bytes.Length-1)])

        [PSCustomObject]@{
            Name = $Rec.name
            TTL = $Rec.TTL
            Flags = $Flags
            Tag   = $Tag
            Value = $Value
        }
    }
}
```


Google.. returned as string, only need to split.
```PowerShell
function Get-CAARecordGoogle {
    param(
        [string]$Domain
    )
    
    try {
        $Response = Invoke-RestMethod "https://dns.google/resolve?name=$Domain&type=CAA" -ErrorAction Stop
        $Records = $Response.Answer | Where-Object {$_.type -eq 257}
    }
    catch {
        break
    }

    foreach ($Rec in $Records) {
        $Parts = $Rec.data -split ' ',3
        [PSCustomObject]@{
            Name  = $Rec.name.TrimEnd('.')
            TTL   = $Rec.TTL
            Flags = [int]$Parts[0]
            Tag   = $Parts[1]
            Value = $Parts[2].Trim('"')
        }
    }
}
```
