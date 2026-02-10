# WDAC / Appcontrol for business

### Install Microsoft.OSConfig PowerShell-module
```PwSh
Install-Module -Name Microsoft.OSConfig -Scope AllUsers -Repository PSGallery -Force
```


### Audit mode on
```PwSh
# Application Control for Business - Audit
Set-OSConfigDesiredConfiguration -Scenario AppControl\WS2025\DefaultPolicy\Audit -Default
Set-OSConfigDesiredConfiguration -Scenario AppControl\WS2025\AppBlockList\Audit -Default
```

### Check block/audit events (if no SIEM)
```Pwsh
# Clear the eventlog before testing for cleaner export files.
# wevtutil cl "Microsoft-Windows-CodeIntegrity/Operational"

# Check eventlogs
$Events = (Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" | ? {$_.Id -match "(3076|3077)"})
$Clean = ($Events | select -ExpandProperty Message) `
    -replace 'Code Integrity determined that a process ' `
    -replace ' attempted to load ', ';' `
    -replace 'that did not meet the Enterprise signing level requirements or violated code integrity policy' `
    -replace '. However, due to code integrity auditing policy, the image was allowed to load.' `
    -replace '\(Policy ID:{.+}\)'

$PSObject = foreach ($line in $Clean) {
    $parts = $line -split ";"
    [PSCustomObject]@{
        Process = $parts[0]
        Loaded = $parts[1]
    }
}
$PSObject


# Or filter on time (only last hour etc)
$Events = (Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" | ? {
    $_.TimeCreated -gt (Get-Date).AddHours(-1)-and $_.Id -match "(3076|3077)"
})
$Clean = ($Events | select -ExpandProperty Message) `
    -replace 'Code Integrity determined that a process ' `
    -replace ' attempted to load ', ';' `
    -replace 'that did not meet the Enterprise signing level requirements or violated code integrity policy' `
    -replace '. However, due to code integrity auditing policy, the image was allowed to load.' `
    -replace '\(Policy ID:{.+}\)'

$PSObject = foreach ($line in $Clean) {
    $parts = $line -split ";"
    [PSCustomObject]@{
        Process = $parts[0]
        Loaded = $parts[1]
    }
}
$PSObject
```

### Create rules from eventlogs?
Eventlog exports can be imported into WDAC Wizard, and automatically suggest new rules.


### Supplemental Policy - Add to base
```PwSh
# Path + AppName
$policyPath = 'C:\wdac\Cortex_Supplemental_v10.0.0.1.xml'
$AppName = 'Cortex'

# Reset GUID (best practice)
Set-CIPolicyIdInfo -FilePath $policyPath -ResetPolicyID

# Set policy version (VersionEx in the XML file)

$policyVersion = "10.0.0.1"

Set-CIPolicyVersion -FilePath $policyPath -Version $policyVersion

# Set policy info (PolicyName and PolicyID in the XML file)

Set-CIPolicyIdInfo -FilePath $policyPath -PolicyID "$AppName-Policy_$policyVersion" -PolicyName "$AppName-Policy"

$base = "{9214D8EE-9B0F-4972-9073-A04E917D7989}"

Set-CIPolicyIdInfo -FilePath $policyPath -SupplementsBasePolicyID $base

#Set the new policy into the system

Set-OSConfigDesiredConfiguration -Scenario AppControl -Name Policies -Value $policyPath
```

### Check status of effective policies and their bases
```Pwsh
# citool is present on windows server 2025, not 2022.
(citool -lp -j | ConvertFrom-Json).policies | select BasePolicyID, FriendlyName, VersionString, IsEnforced | Sort-Object BasePolicyID
```

### Enforce - when all supplemental policies are made for non-windows applications, and 3076 events are gone from logs -> Enforce
```PwSh
# Application Control for Business - Enforced
Set-OSConfigDesiredConfiguration -Scenario AppControl\WS2025\DefaultPolicy\Enforce -Default
Set-OSConfigDesiredConfiguration -Scenario AppControl\WS2025\AppBlockList\Enforce -Default
```
