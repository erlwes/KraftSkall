Calculated properties

This is usefull when ...
1. renaming property labels
2. re-calculating property values
3. expanding nested properties
4. adding custom properties

Works with Format-Table, Format-list and Select-Object.
Both "name" and "label" can be used. One is kept for backward compatability with earlier versions of PS. I dont remember which one.

```PowerShell
Get-Process | Format-Table -Property Name, @{name='VM(MB)';expression={$_.VM/1MB -as [int]};formatstring='F2';align='right'} -AutoSize
$Properties = @(    
    @{Name = 'Name'; expression = { $_.ProcessName}} #re-name
    'Id' #Just select. Do nothing with value or name.
    @{Name = 'VM(MB)';expression = {($_.VM / 1MB) -as [int]}} #re-calculate existing property    
    @{Name = 'Custom';expression = {(hostname)}} #Add custom property (anything)
    @{Name = 'WaitReasons'; expression = { $_.Threads.WaitReason}} #Extract nested property
)
Get-Process | Select-Object $Properties
```