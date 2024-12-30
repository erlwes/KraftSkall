# ROUNDING
#PS C:\> $a = 200 / 66
#PS C:\> [math]::Round($a,2)
#3,03


# PRACTICAL EXAMPLE:
$Drives = @()
Get-PSDrive -PSProvider FileSystem -Name C, D | select Name, Used, Free | % {
    $Obj = [PSCustomObject]@{
        Name = $_.Name
        TotalGB = [math]::Round((($_.Used + $_.Free) / 1024 / 1024 / 1024),2)
        UsedGB = [math]::Round((($_.Used) / 1024 / 1024 / 1024),2)
        FreeGB = [math]::Round((($_.Free) / 1024 / 1024 / 1024),2)
        FreePercentage = [math]::Round(($_.Free / ($_.Free + $_.Used) * 100),2)
    }
    $Drives += $Obj
}
$Drives

#Name           : C
#TotalGB        : 299,4
#UsedGB         : 186,44
#FreeGB         : 112,95
#FreePercentage : 37,73

#Name           : D
#TotalGB        : 4095,98
#UsedGB         : 1086,22
#FreeGB         : 3009,76
#FreePercentage : 73,48
