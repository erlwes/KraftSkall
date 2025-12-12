# Security Baselines - 2022/2025 member servers

```PwSh
# Install module
Install-Module -Name Microsoft.OSConfig -Scope AllUsers -Repository PSGallery -Force

# Security Baselines - Server 2022 or 2025 for domain joined member servers
$ServerEdition = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductName
if $($ServerEdition -match 'Server 2022') { $Scenario = 'SecurityBaseline\Server\2022\MemberServer' }
if $($ServerEdition -match 'Server 2025') { $Scenario = 'SecurityBaseline\WS2025\MemberServer'      }

# Set security baselines defaults
Set-OSConfigDesiredConfiguration -Scenario $Scenario -Default

# Allow clipboard re-dir?
Set-OSConfigDesiredConfiguration -Scenario $Scenario -Name RemoteDesktopServicesDoNotAllowDriveRedirection -Value 0

# If 2025, remove the default logon-message
if $($ServerEdition -match 'Server 2025') { 
    Set-OSConfigDesiredConfiguration -Scenario $Scenario -Name MessageTextUserLogon -Value ''
    Set-OSConfigDesiredConfiguration -Scenario $Scenario -Name MessageTextUserLogonTitle -Value ''
}

# Run GPUpdate, so that domain policy instantly will revert some changes, if there are "conflicts". Consider a reboot.
GPUpdate /force

# Then check compliance (compare local settings vs. security baselines)
$SecurityStatus = Get-OSConfigDesiredConfiguration -Scenario $Scenario | Select-Object `
    Name,
    @{N="Severity";E={$_.Compliance.Severity}},
    @{N="Status";E={$_.Compliance.Status}},
    @{N="Reason";E={$_.Compliance.Reason}}    

$SecurityStatus | ? {$_.Status -ne 'Compliant'} | Format-Table * -AutoSize -Wrap

# If Critical settings are reverted by domain policies, consider hardening the GPO.
```

Source: https://learn.microsoft.com/en-us/windows-server/security/osconfig/osconfig-how-to-configure-app-control-for-business?tabs=configure%2Cview
