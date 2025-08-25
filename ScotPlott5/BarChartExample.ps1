Add-Type -Path .\ScottPlot.dll
Import-Module Sixel

# Reference -> https://scottplot.net/cookbook/5.0/

# Add a new Plot
$Plot = [ScottPlot.Plot]::new()

# Set background colors. Uncomment for defaults
#$Plot.FigureBackground.Color = [ScottPlot.Colors]::DimGray
#$Plot.DataBackground.Color   = [ScottPlot.Colors]::Gainsboro

# Control padding around figures. If long labels, padding needs to be increased to avoid cropping
$Padding = [ScottPlot.PixelPadding]::new(70, 70, 100, 60) #left, right, bottom, top
$Plot.Layout.Fixed($Padding)

# Set titles
$Plot.Title("Title of the chart")
$Plot.YLabel("Y-Axis")
#$Plot.XLabel("X-Axis")

# Control grid
#$Plot.Grid.MajorLineColor = [ScottPlot.Colors]::LightGrey
#$Plot.Grid.MinorLineColor = [ScottPlot.Colors]::LightGrey
$Plot.Grid.MajorLineWidth = 1
$Plot.Grid.MinorLineColor = 1
#$Plot.HideGrid()

# Control Ticks
$Plot.Axes.Bottom.MajorTickStyle.Color = [ScottPlot.Colors]::Black
$Plot.Axes.Bottom.MinorTickStyle.Color = [ScottPlot.Colors]::Black
$Plot.Axes.Left.MajorTickStyle.Color = [ScottPlot.Colors]::Black
$Plot.Axes.Left.MinorTickStyle.Color = [ScottPlot.Colors]::Black

# Control size on bottom ticks (0 = hide)
$Plot.Axes.Bottom.MajorTickStyle.Length = 5

# Style axis labels
$Plot.Axes.Margins(0.05, 0.05, 0, 0.08)  #left, right, bottom, top

# Label rotate? -> 0 or uncomment to remove rotation
$Plot.Axes.Bottom.TickLabelStyle.Rotation = 45
$Plot.Axes.Bottom.TickLabelStyle.Alignment = [ScottPlot.Alignment]::UpperLeft

# Control font name
$Plot.Axes.Title.Label.FontName = 'Monospace'
$Plot.Axes.Left.Label.FontName = 'Monospace'
$Plot.Axes.Bottom.Label.FontName = 'Monospace'
$Plot.Axes.Bottom.TickLabelStyle.FontName = 'Monospace'

# Control font colors
$Plot.Axes.Title.Label.ForeColor = [ScottPlot.Colors]::Black
$Plot.Axes.Left.Label.ForeColor = [ScottPlot.Colors]::Black
$Plot.Axes.Bottom.Label.ForeColor = [ScottPlot.Colors]::Black
$Plot.Axes.Bottom.TickLabelStyle.ForeColor = [ScottPlot.Colors]::Black

# Build Bar objects (loop through objects and add for each)
$Values = @()
$Bars = New-Object 'System.Collections.Generic.List[ScottPlot.Bar]'
$Bar = [ScottPlot.Bar]::new(); $Bar.Position = 1; $Bar.Value = 10;  $Values += $Bar.Value;  $Bars.Add($Bar)
$Bar = [ScottPlot.Bar]::new(); $Bar.Position = 2; $Bar.Value = 20;  $Values += $Bar.Value;  $Bars.Add($Bar)
$Bar = [ScottPlot.Bar]::new(); $Bar.Position = 3; $Bar.Value = 80;  $Values += $Bar.Value;  $Bars.Add($Bar)
$Bar = [ScottPlot.Bar]::new(); $Bar.Position = 4; $Bar.Value = 65;  $Values += $Bar.Value;  $Bars.Add($Bar)
$Bar = [ScottPlot.Bar]::new(); $Bar.Position = 5; $Bar.Value = 180; $Values += $Bar.Value;  $Bars.Add($Bar)
$Bar = [ScottPlot.Bar]::new(); $Bar.Position = 6; $Bar.Value = 40;  $Values += $Bar.Value;  $Bars.Add($Bar)

# Color each bar with different color from a palette  ->  https://scottplot.net/cookbook/5.0/palettes/
$palette = $Plot.Add.Palette = [ScottPlot.Palettes.Microcharts]::new()
for ($i = 0; $i -lt $Bars.Count; $i++) {
    $Bars[$i].FillColor = $Palette.GetColor($i)
    $Bars[$i].LineColor = $Bars[$i].FillColor.Darken(0.5) # nice border
}

# Add labels on top of bars (combine in one loop with above if you want both palette coloring and labels on top)
for ($i = 0; $i -lt $Bars.Count; $i++) {    
    $Bars[$i].Label = $Bars[$i].Value.ToString()

    # Remove decimals from nummeric values?
    #$Bars[$i].Label = ("{0:N0}" -f $Bars[$i].Value)
}

# Add the series of bars
$BarPlot = ($Plot.Add.Bars($Bars))   # parentheses are important in PowerShell

# Color all bars in one color, after creating the plot?
#$BarPlot.Color = [ScottPlot.Colors]::LightCoral
#$labels = $Bars | ForEach-Object { $_.Value.ToString() }



# Add labels to bottoms ticks along x-axis
$ticks = [ScottPlot.Tick[]]@(
    [ScottPlot.Tick]::new(1, "Cheese"),
    [ScottPlot.Tick]::new(2, "Milk"),
    [ScottPlot.Tick]::new(3, "Apple"),
    [ScottPlot.Tick]::new(4, "Toast"),
    [ScottPlot.Tick]::new(5, "Ice cream"),
    [ScottPlot.Tick]::new(6, "Youghurt")
)
$Plot.Axes.Bottom.TickGenerator = [ScottPlot.TickGenerators.NumericManual]::new($ticks)


# Save Image as a file? No, not today.
#$Plot.SavePng("C:\script\ScottPlot5\PSTest\servers_bars_v5.png", 2000, 1500)

# Get Image bytes
[byte[]]$pngBytes = $Plot.GetImageBytes(900, 600)

# Add bytes to memory stream
$ms = [System.IO.MemoryStream]::new($pngBytes)

# Rewind to start, ready to be piped
$null = $ms.Seek(0, [System.IO.SeekOrigin]::Begin)

# Pipe it to Sixel, to display in console
$ms | ConvertTo-Sixel
