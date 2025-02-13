# This is a quick way to discover permissions needed to run all cmdlets you plan to use in a script

```PowerShell
$cmds = @(
 "Get-MgUser",
 "Get-MgTeam",
 "Get-MgSite"
)
$perms = New-Object System.Collections.ArrayList
$cmds | ForEach-Object {(Find-MgGraphCommand -Command $_).Permissions[0] | ForEach-Object {$perms.Add($_.Name)}}
$perms | Select -Unique
```

Then consent:
Connect-MgGraph -Scopes $perms

Some APIs require more than one permission, so you may need to remove [0] to see them all. Be careful as this returns all permissions.
