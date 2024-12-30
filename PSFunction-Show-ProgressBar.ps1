Function Show-ProgressBar {
    param(
        [int]$Percentage,
        [string]$Task = "",
        [ValidateRange(10,100)][int]$BarWidth = 40,
        [ValidateSet(
            "Black", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow", "Gray", 
            "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White"
        )][string]$Color,
        [datetime]$StartTime,
        [switch]$EmojiMode
    )
    
    if ($Color -and $EmojiMode) {
        Write-Host 'Show-ProgressBar - The parameters "-EmojiMode" and "-Color" can not be used in combination!' -ForegroundColor Red
        Break
    }

    #Hide the cursor to avoid blinking/render issues in console
    [console]::CursorVisible = $false

    #If a start time is provided - calculate elapsed and remaining time.
    if ($StartTime) {        
        $elapsed = (Get-Date) - $script:StartTime
        $remainingTime = if ($Percentage -gt 0) { 
            $elapsed * (100 - $Percentage) / $Percentage 
        } else { [timespan]::Zero }
        $remainingText = "/ ETA: " + $remainingTime.ToString("hh\:mm\:ss")
    }
    else {
        $remainingText = ''
    }    
    
    #If not static color, assign dynamic colors. Color and emojimode can not be used the the same time now...
    if (!$Color) {
        if      ($Percentage -lt 25) { $Color = 'DarkRed'; $Emoji = '🔴'}
        elseif  ($Percentage -lt 50) { $Color = 'Red';     $Emoji = '🟠'}
        elseif  ($Percentage -lt 80) { $Color = 'Yellow';  $Emoji = '🟡'}
        else                         { $Color = 'Green';   $Emoji = '🟢'}
    }
    
    #Determine progressbar looks from percentage
    $filledWidth = [Math]::Truncate(($Percentage / 100) * $BarWidth)
    if ($EmojiMode) {
        $filledSection = $Emoji * $filledWidth
        $unfilledSection = '⚪' * ($BarWidth - $filledWidth)
    }
    else {
        $filledSection = '#' * $filledWidth
        $unfilledSection = '-' * ($BarWidth - $filledWidth)
    }    
    
    if ($Percentage -lt 100) {
        if ($EmojiMode) {
            $filledSection += "⚪"
        }
        else {
            $filledSection += ">"
        }
        $unfilledSection = $unfilledSection.Substring(1)
        
    }
    else {        
        $remainingText = '/ Done'
        [console]::CursorVisible = $true        
    }
    
    if ($StartTime) {
        Write-Host -NoNewline "`r[$($elapsed.ToString("hh\:mm\:ss"))] ["
    }
    else {
        Write-Host -NoNewline "`r["
    }

    Write-Host -NoNewline "$filledSection" -ForegroundColor $Color    
    Write-Host -NoNewline "$unfilledSection"
    Write-Host -NoNewline "] $Task - $Percentage% $remainingText          "
    # Added extra space after $remainingText to overwrite previous elapsed time when done.
}

#Test loop...
$p = 0
$StartTime = (Get-Date)
While ($p -le 100) {
    Start-Sleep -Seconds 0.05
    Show-ProgressBar -Percentage $p -BarWidth 30 -Task 'Counting sheeps' -StartTime $StartTime -EmojiMode
    $p = ($p + 2)
}

$p = 0
$StartTime = (Get-Date)
While ($p -le 100) {
    Start-Sleep -Seconds 0.05
    Show-ProgressBar -Percentage $p -BarWidth 30 -Task 'Counting sheeps' -StartTime $StartTime -Color Red
    $p = ($p + 2)
}
