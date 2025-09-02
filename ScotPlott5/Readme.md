# Notes from testing ScotPlott 5 in PowerShell Core

### Test setup
1. ScotPlott 5.0.56 built with dotnet 10 (https://scottplot.net/quickstart/powershell/)
2. Tests ran in PowerShell 7.5.0 with Sixel 0.5.0
3. Windows 11 24H2
<img width="503" height="315" alt="image" src="https://github.com/user-attachments/assets/847d7135-bebf-4941-ad5e-7de387380063" />

### Output from BarChartExample.ps1
<img width="907" height="568" alt="image" src="https://github.com/user-attachments/assets/cc082756-d9d3-4e54-b64a-6139b773f0af" />

### Output from ProcessByCPUBarChart.ps1
<img width="862" height="568" alt="image" src="https://github.com/user-attachments/assets/64680ccd-2539-41f6-8ed9-7cb5b0e2689e" />

### Output from ScatterChart.ps1
<img width="574" height="343" alt="image" src="https://github.com/user-attachments/assets/80501881-57e6-441e-84c9-d56061f51dca" />

### Output from ScatterChartTempOslo
<img width="1006" height="358" alt="image" src="https://github.com/user-attachments/assets/0fd4abcc-5c96-41f8-a5c5-722e6a27e6b6" />


### Fun with Sixel
```PowerShell
Invoke-WebRequest -Uri "https://www.tu.no/tegneserier/lunch" | select -ExpandProperty images | ? {$_.OuterHTML -match 'lunch'} | select -ExpandProperty src | % {ConvertTo-Sixel -Url $_}
```
