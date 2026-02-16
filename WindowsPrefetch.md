# Windows Prefetch

### Build PECmd
```
git clone https://github.com/EricZimmerman/PECmd
cd PECmd
dotnet restore
dotnet build
```

### Create Json
```PwSh
$peCmd   = "C:\script\PECmd\PECmd.exe"
$pfPath  = "$env:windir\Prefetch"
$outDir  = "C:\script\PECmd\Out"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
& $peCmd -d $pfPath --json $outDir --jsonf prefetch.json
```

### Import JSON and create objects
```PwSh
$outDir  = "C:\script\PECmd\Out"
$path = "$outDir\prefetch.json"
$Objects = Get-Content -LiteralPath $path | Where-Object { $_.Trim() -ne "" } | ForEach-Object {
  $_ | ConvertFrom-Json
}

# PowerShell can not know the types of imported data, so we have to tell it whats what, so the sorting works :)
$FixedObjects = $Objects | ForEach-Object {
    $o = $_
    $out = [pscustomobject]([ordered]@{})

    foreach ($p in $o.PSObject.Properties) {
        $name  = $p.Name
        $value = $p.Value
        
        if ($null -eq $value) {
            $out | Add-Member -NotePropertyName $name -NotePropertyValue $null -Force
            continue
        }
        
        if ($value -is [System.Collections.IEnumerable] -and -not ($value -is [string])) {
            $out | Add-Member -NotePropertyName $name -NotePropertyValue $value -Force
            continue
        }

        switch -Regex ($name) {

            # int
            '^(RunCount|Size)$' {
                $value = $value -as [int]
                break
            }

            # datetime
            '^(SourceCreated|SourceModified|SourceAccessed|LastRun)$' {
                $value = $value -as [datetime]
                break
            }
            '^PreviousRun\d+$' {
                $value = $value -as [datetime]
                break
            }
            '^Volume\d+Created$' {
                $value = $value -as [datetime]
                break
            }

            # bool
            '^(ParsingError)$' {
                $value = $value -as [bool]
                break
            }
        }

        # Also coerce generic True/False strings anywhere
        if ($value -is [string] -and $value -match '^(?i:true|false)$') {
            $value = $value -as [bool]
        }

        $out | Add-Member -NotePropertyName $name -NotePropertyValue $value -Force
    }

    $out
}
```

$FixedObjects | Sort-Object RunCount -Descending | Format-Table SourceFilename, RunCount, Size, LastRun -Auto
