# https://ourcloudnetwork.com/list-all-directory-objects-owned-by-a-user-in-entra-with-powershell/

```PowerShell
function Get-OcnMgOwnedObject {
    param(
        $userid
    )
    $response = invoke-MgGraphRequest -uri "https://graph.microsoft.com/beta/users/$userid/ownedObjects" -OutputType PSObject | Select -ExpandProperty Value 
    $report = [System.Collections.Generic.List[Object]]::new()
    forEach ($item in $response) {
        switch ($item.'@odata.type')
{
    '#microsoft.graph.group' { $type = 'Group' }
    '#microsoft.graph.application' { $type = 'Application' }
    '#microsoft.graph.servicePrincipal' { $type = 'Service Principal' }
}
        $obj = [PSCustomObject][ordered]@{
            "Type" = $type
            "Display Name" = $item.DisplayName
            "Object Id" = $item.id
        }
        $report.Add($obj)
    }
    $report
}
```

Get-OcnMgOwnedObject -userid example@ourcloudnetwork.com
