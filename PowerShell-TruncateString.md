# Trancate characters above 32 in length
```PowerShell
$string = "The brown quick fox jumped over the fence."
$string.Substring(0, [System.Math]::Min(32, $string.Length))
```
```The brown quick fox jumped over ```

# Trancate characters above 29 in length, and visually show that it is truncated.
```PowerShell
$string = "The brown quick fox jumped over the fence."
"$($string.Substring(0, [System.Math]::Min(29, $string.Length)))..."
```
```The brown quick fox jumped ov...```
