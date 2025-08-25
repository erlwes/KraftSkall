Add-Type -Path .\ScottPlot.dll # <- Dependencies are loaded when placed in same folder as ScottPlot.dll (SkiaSharp, libSkiaSharp ++ )
Import-Module Sixel

# Get some data. Getting air temperature forecast from Oslo in this example:
$Hours = 12
$OsloWeatherForeCast = Invoke-RestMethod "https://api.met.no/weatherapi/locationforecast/2.0/complete?lat=59.9333&lon=10.7166"
$NextXHours = $OsloWeatherForeCast.properties.timeseries[0..($Hours + 2)]
$StartDate = $NextXHours[0].time -replace '\s.+$'


# New plot
$Plot = [ScottPlot.Plot]::new()

# Add title
$Plot.Title("$($StartDate): Air temperator Oslo, next $Hours hours")

# Ready number of values for x-axis
[double[]]$x = 0..$($NextXHours.count)


# Title left (Y-axis)
$Plot.YLabel("Celsius")

# Ready ordered values for y-axis
[double[]]$y = @(
    for ($i = 0; $i -lt $NextXHours.Count; $i++) {    
        $NextXHours[$i ].data.instant.details.air_temperature
    }
)

# Add y & y values to scatter chart
[void]$Plot.Add.Scatter($x, $y)


# Add ticks with labels (time)
$ticks = [ScottPlot.Tick[]]@(
    for ($i = 0; $i -lt $NextXHours.Count; $i++) {
        [ScottPlot.Tick]::new($i, "$($NextXHours[$i].time -replace '.+\s')")
    }
)
$Plot.Axes.Bottom.TickGenerator = [ScottPlot.TickGenerators.NumericManual]::new($ticks)


# Add 70 pixels of widt of each tick (room). Gibes space for a date in format dd.mm.yyyy per tick with decent spacing for readability
$Width = $NextXHours.count * 70

# But dont let it get cray high :P
if ($Width -gt 2000) {$Width = 2000}


# Save to file? (not today)
# [Void] $Plot.SavePng("$pwd\quickstart.png", $Width, 300)

# Get Image bytes
[byte[]]$pngBytes = $Plot.GetImageBytes($Width, 300)

# Add bytes to memory stream
$ms = [System.IO.MemoryStream]::new($pngBytes)

# Rewind to start, ready to be piped
$null = $ms.Seek(0, [System.IO.SeekOrigin]::Begin)

# Pipe it to Sixel, to display in console
$ms | ConvertTo-Sixel
