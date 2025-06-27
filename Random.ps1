Get-NetNeighbor -AddressFamily IPv4
arp -a

Get-NetNeighbor -AddressFamily IPv4 | select -ExpandProperty IPAddress -Unique
(arp -a | select -Skip 3) -replace '..-..-..-..-..-..' -replace "(static|dynamic)" -replace '\s'
   
Get-DnsClientCache
ipconfig /displaydns

#Get loaded assembly
[System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object -FilterScript { $_.Location } | Sort-Object -Property FullName

#Remove empty lines
(gc data.txt) | ? { -not [String]::IsNullOrWhiteSpace($_) } | sc data.txt

#Install ISE
Get-WindowsCapability -Name Microsoft.Windows.PowerShell.ISE~~~~0.0.1.0 -Online | Add-WindowsCapability -Online -Verbose

#New ScriptInfo
New-ScriptFileInfo -Path 'C:\Users\Temp\MyScript.ps1'
Publish-Script -Path 'C:\Users\Temp\MyScript.ps1' -NuGetApiKey xxxxxxxxxx


#CISCO cable test length
#COM PORT RATE = 115200
show cable-diagnostics
test cable-diagnostics tdr interface Fivegigabit1/0/[portnumber]

