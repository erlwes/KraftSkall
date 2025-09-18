#Timed one time passcodes

My notes from

```PowerShell
# Convert Base32 to bytes
Function Convert-Base32ToBytes {
    param ([string]$Base32)
    $Base32Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    $Bytes = @()
    $Base32 = $Base32.ToUpper().Replace("=", "")
    $BitBuffer = 0
    $BitBufferLength = 0

    foreach ($char in $Base32.ToCharArray()) {
        $BitBuffer = ($BitBuffer -shl 5) -bor ($Base32Alphabet.IndexOf($char))
        $BitBufferLength += 5

        while ($BitBufferLength -ge 8) {
            $BitBufferLength -= 8
            $Bytes += [byte](($BitBuffer -shr $BitBufferLength) -band 0xFF)
        }
    }
    return ,$Bytes
}

# Create new seed/secret key (Base32)
Function New-Base32SecretKey {
    param ([int]$Length = 32)
    $Base32Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    $SeedKey = ""
    for ($i = 0; $i -lt $Length; $i++) {
        $RandomIndex = Get-Random -Minimum 0 -Maximum $Base32Alphabet.Length
        $RandomChar = $Base32Alphabet[$RandomIndex]
        $SeedKey += $RandomChar
    }
    return $SeedKey
}

# Get current and previous passcode (defaults: 2 digits, 1-hour step)
Function Get-TOTP {
    param (
        [string]$Secret,
        [int]$Digits = 6,
        [int]$Interval = 30,
        [ValidateSet('SHA1','SHA256','SHA512')]
        [string]$Algo = 'SHA1'   # optional: pick a hash algo
    )

    # Convert secret to byte array
    $KeyBytes = Convert-Base32ToBytes -Base32 $Secret

    $UnixTime    = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $CurrentStep = [int64]($UnixTime / $Interval)
    $Results     = @()
    $mod         = [int][math]::Pow(10, $Digits)

    foreach ($StepOffset in -1..0) {
        $Step = $CurrentStep + $StepOffset
        $StepBytes = [BitConverter]::GetBytes([System.Net.IPAddress]::HostToNetworkOrder($Step))

        switch ($Algo) {
            'default' {$hmac = [System.Security.Cryptography.HMACSHA1]::new($KeyBytes)}
            'SHA256'  {$hmac = [System.Security.Cryptography.HMACSHA256]::new($KeyBytes)}
            'SHA512'  {$hmac = [System.Security.Cryptography.HMACSHA512]::new($KeyBytes)}
            
        }

        try {
            $Hash = $hmac.ComputeHash($StepBytes)
        } finally {
            $hmac.Dispose()
        }

        $Offset = $Hash[-1] -band 0x0F
        $Binary =
            (($Hash[$Offset]     -band 0x7F) -shl 24) -bor
            (($Hash[$Offset + 1] -band 0xFF) -shl 16) -bor
            (($Hash[$Offset + 2] -band 0xFF) -shl 8)  -bor
            ($Hash[$Offset + 3]  -band 0xFF)

        $OTP = $Binary % $mod
        $Results += $OTP.ToString().PadLeft($Digits, '0')
    }
    return $Results
}
```

<img width="925" height="267" alt="image" src="https://github.com/user-attachments/assets/323994ca-7979-4ccd-9636-c8abe3b4b1c0" />
