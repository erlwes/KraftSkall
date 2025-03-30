### Function:
```PowerShell
Function Show-ProgressBar {
    param(
        [int]$Percentage,
        [string]$Task = "",
        [ValidateRange(10,100)][int]$BarWidth = 40,
        [ValidateSet(
            "Black", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow", "Gray", 
            "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White"
        )][string]$Color
    )

    #Hide the cursor to avoid blinking/render issues in console
    [console]::CursorVisible = $false

    #If not static color, assign dynamic colors.
    if (!$Color) {        
        if      ($Percentage -lt 30) { $Color = 'Red'}
        elseif  ($Percentage -lt 60) { $Color = 'Yellow'}
        else                         { $Color = 'Green'}
    }

    #Determine progressbar looks from percentage
    $filledWidth = [Math]::Truncate(($Percentage / 100) * $BarWidth)
    $filledSection = '#' * $filledWidth
    $unfilledSection = '-' * ($BarWidth - $filledWidth)

    if ($Percentage -lt 100) {
        $filledSection += ">"
        $unfilledSection = $unfilledSection.Substring(1)
    }
    else {
        $remainingText = '/ Done'
        [console]::CursorVisible = $true
    }

    Write-Host -NoNewline "`r["
    Write-Host -NoNewline "$filledSection" -ForegroundColor $Color
    Write-Host -NoNewline "$unfilledSection"
    Write-Host -NoNewline "] $Task - $Percentage% $remainingText                   " #20x whitespace for overwriting previous line completley if different lenght on task.
}
```

### Example processing an object or array
```PowerShell
[decimal]$Percent = 0
$ProcessedObjects = 0
$Object = Get-Process
$Object | ForEach-Object {
    Start-Sleep -Seconds 0.01
    $ProcessedObjects ++
    Show-ProgressBar -Percentage ([Math]::Round($Percent)) -BarWidth 30 -Task "$ProcessedObjects/$($Object.count) Current task: $($_.processName)" -StartTime $StartTime
    [decimal]$Percent += [decimal](100 / $Object.count)
}
```
