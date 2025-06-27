# Replace 1st occurence of "fox" with "bear"
```PowerShekll
$string = 'The quick brown fox is a sly fox'
[regex]$word = "fox"
$word.replace($string, "bear", 1)
```
```The quick brown bear is a sly fox```

# Replace 1st occurence of "fox" with "bear", starting from the end of the string
```PowerShekll
$string = 'The quick brown fox is a sly fox'
[regex]$word = "(fox)$"
$word.replace($string, "bear", 1)
```
```The quick brown fox is a sly bear```

# Replace 2 occurences of "fox" with "bear"
```PowerShekll
$string = 'The quick brown fox is a sly fox'
[regex]$word = "fox"
$word.replace($string, "bear", 2)
```
```The quick brown bear is a sly bear```
