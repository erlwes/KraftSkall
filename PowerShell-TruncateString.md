# Truncate characters above 32 in length
```PowerShell
$string = "The brown quick fox jumped over the fence."
$string.Substring(0, [System.Math]::Min(32, $string.Length))
```
```The brown quick fox jumped over ```

# Same, different method (easier)
```PowerShell
$string = "The brown quick fox jumped over the fence."
$string[0..31] -join ""
```
```The brown quick fox jumped over ```

# Truncate characters above 29 in length, and visually show that it is truncated.
```PowerShell
$string = "The brown quick fox jumped over the fence."
"$($string.Substring(0, [System.Math]::Min(29, $string.Length)))..."
```
```The brown quick fox jumped ov...```
