#Sometimes we want to output the commands to so something, instead of actually doing it at runtime.
#But in order for the commands to work outside the script scope, the variabled needs to be calculated/expanded/written out.. AND if the ariables have spaces, then need to be wrapped with "/'.
#Below is an example for later use.

$Name = 'Økonomi avdelingen'
$Obj = New-Object PSObject
$Obj | Add-Member -MemberType NoteProperty -Name Alias -Value ($Name -replace ',' -replace ' ','-' -replace "(æ|å)", 'a' -replace 'ø', 'o').ToLower()
$Obj | Add-Member -MemberType NoteProperty -Name DisplayName -Value ("Contoso - $Name")
$Obj | Add-Member -MemberType NoteProperty -Name SMTP -Value ("$($Obj.Alias)@contoso.com")
$Obj | Add-Member -MemberType NoteProperty -Name Department -Value $Name

$Commands = @()
$Obj | ForEach-Object {

    $DisplayName = $_.DisplayName -replace '^', '"' -replace '$', '"'
    $Filter = "(RecipientType -eq 'UserMailbox') -and (Department -like '$($_.Department)')" -replace '^', '"' -replace '$', '"'
    $Alias = $_.Alias -replace '^', '"' -replace '$', '"'
    $SMTP = $_.SMTP -replace '^', '"' -replace '$', '"'

    $String = "New-DynamicDistributionGroup -Name $DisplayName -DisplayName $DisplayName -RecipientFilter $Filter -Alias $Alias -PrimarySmtpAddress $SMTP -Confirm:$false"
    $Commands += $String
}

Write-Host $Commands
