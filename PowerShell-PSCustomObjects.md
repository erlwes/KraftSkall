#Add all members one by one
$Obj = New-Object PSObject
$Obj | Add-Member -MemberType NoteProperty -Name Type -Value Apple
$Obj | Add-Member -MemberType NoteProperty -Name Colour -Value Red

#Add property while delclearing object, then later add a member
$Obj = New-Object PSObject -property @{Type = 'Apple'}
$Obj | Add-Member -MemberType NoteProperty -Name Colour -Value Red

#Add all members while declaring object. Easier to write and remember I believe.
$Obj = New-Object PSObject -property @{
    Type = 'Apple'
    Colour = 'Red'
}

### Easiest?
```PowerShell
$Obj = [PSCustomObject]@{
    Type = 'Apple'
    Colour = 'Red'
}
```

#Example with nested properties
$Obj = [PSCustomObject]@{
    Type = 'Apple'
    Colour = 'Red'
    Size = @{
        DiameterCM = 12
        WeightKG = 0.2
    }
}
