# examples of powershell parameter validation attributes
[cmdletbinding()]
param(
    #region Mandatory parameter with validation set
    [ValidateNotNullOrEmpty()]
    [string]$Name,
    #endregion

    #region Better mandatory parameter.
    [parameter(Mandatory = $true)]
    [string]$MandatoryName,
    #endregion

    #region ValidateRange example
    [ValidateRange(1, 69)]
    [int]$Age,
    #endregion

    #region ValidateCount example
    [ValidateCount(1, 5)]
    [string[]]$Tags,
    #endregion

    #region ValidateSet example
    [ValidateSet('Admin', 'User', 'Guest')]
    [string]$Role = 'User',
    #endregion

    #region Advanced ValidateSet example
    [ValidateSet('Admin', 'User', 'Guest', IgnoreCase = $false)]
    [string]$RoleCaseSensitive = 'User',
    #endregion


    #region ValidatePattern example
    [ValidatePattern('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')]
    [string]$Email,
    #endregion

    #region Better email validation using class types
    [ValidateNotNullOrEmpty()]
    [System.Net.Mail.MailAddress]$EmailAddress,
    #endregion

    #region ValidateScript example (check if file exists)
    [ValidateScript({
        if (Resolve-Path $_) {
            return $true
        } else {
            throw "File '$($_)' does not exist."
        }
    })]
    [string]$FilePath,
    #endregion

    #region better file validation using class types AND ValidateScript
    [ValidateScript({ Test-Path $_.FullName }, ErrorMessage = "File '{0}' does not exist.")]
    [System.IO.FileInfo]$FileInfo
    #endregion
)

#region example values - if the parameter is used, display the values
if ($PSBoundParameters.ContainsKey('Name')) {
    Write-Host "Name: $Name"
}
if ($PSBoundParameters.ContainsKey('MandatoryName')) {
    Write-Host "Mandatory Name: $MandatoryName"
}
if ($PSBoundParameters.ContainsKey('Age')) {
    Write-Host "Age: $Age"
}
if ($PSBoundParameters.ContainsKey('Tags')) { 
    Write-Host "Tags: $($Tags -join ', ')"
}
if ($PSBoundParameters.ContainsKey('Role')) {
    Write-Host "Role: $Role"
}
if ($PSBoundParameters.ContainsKey('RoleCaseSensitive')) {
    Write-Host "Role (Case Sensitive): $RoleCaseSensitive"
}
if ($PSBoundParameters.ContainsKey('Email')) {
    Write-Host "Email: $Email"
}
if ($PSBoundParameters.ContainsKey('EmailAddress')) {
    Write-Host "Email Address..."
    $EmailAddress | Select-Object *
}
if ($PSBoundParameters.ContainsKey('FilePath')) {
    Write-Host "File Path: $FilePath"
}
if ($PSBoundParameters.ContainsKey('FileInfo')) {
    Write-Host "File Info..."
    $FileInfo | Select-Object *
}
#endregion

#region kevin marquette custom validator example - https://powershellexplained.com/2017-02-20-Powershell-creating-parameter-validators-and-transforms/
class ValidatePathExistsAttribute : System.Management.Automation.ValidateArgumentsAttribute
{
    [void]  Validate([object]$arguments, [System.Management.Automation.EngineIntrinsics]$engineIntrinsics)
    {
        $path = $arguments
        if([string]::IsNullOrWhiteSpace($path))
        {
            Throw [System.ArgumentNullException]::new()
        }
        if(-not (Test-Path -Path $path))
        {
            Throw [System.IO.FileNotFoundException]::new()
        }        
    }
}

function Invoke-KevinDemo {
    [cmdletbinding()]
    param(
        [ValidatePathExists()]
        [System.IO.FileInfo]$Path
    )
    Write-Host "Hello Kevin, the file '$($Path.Name)' exists at '$($Path.FullName)'."
}
#endregion
