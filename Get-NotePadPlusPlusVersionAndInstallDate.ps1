# EXAMPLE 1:
# $ADServers = Get-ADComputer -Filter {Enabled -eq $true -and Operatingsystem -like '*windows server*'} | Select-Object -ExpandProperty Name
# .\Get-NotePadPlusPlusVersionAndInstallDate.ps1 -ComputerNames $ADServers

# EXAMPLE 2:
# 'server01', 'server02' | .\Get-NotePadPlusPlusVersionAndInstallDate.ps1

param (
    [cmdletbinding()]
    [parameter(mandatory=$true, ValueFromPipeline=$true)]$ComputerNames    
)
begin {
    $stopw = [System.Diagnostics.Stopwatch]::StartNew()
    $AllComputers = @()   

    Function Write-Console {
        param(
            [ValidateSet(0, 1, 2, 3, 4)][int]$Level = 0,
            [Parameter(Mandatory=$true)][string]$Message
        )
        $Message = $Message.Replace("`r",'').Replace("`n",' ')

        switch ($Level) {
                  0 { $Status = 'Info'      ;$FGColor = '255;255;255' } #White
                  1 { $Status = 'Success'   ;$FGColor = '90;220;35'   } #Green
                  2 { $Status = 'Warning'   ;$FGColor = '250;210;20'  } #Yellow
                  3 { $Status = 'Error'     ;$FGColor = '220;20;20'   } #Red
                  4 { $Status = 'Highlight' ;$FGColor = '200;200;200' } #Gray
        }
        
        if ($Level -eq 4) {
            Write-Host "`e[38;2;100;100;100m$((Get-Date).ToString()) `e`e[38;2;$($FGColor)m$Status`e[0m`t`e[38;2;70;170;255m$Message`e"
        }
        else {
            Write-Host "`e[38;2;100;100;100m$((Get-Date).ToString()) `e`e[38;2;$($FGColor)m$Status`e[0m`t$Message"
        }
    }
    
}
process {
    
    $allComputers += $ComputerNames
    
}
end {
    Write-Console -Level 0 -Message 'Start'
    Write-Console -Level 0 -Message "Input servers: $($allComputers.count)"        

    $Results = $allComputers | Foreach-Object -ThrottleLimit 20 -Parallel {
        try {

            Function Write-Console {
                param(
                    [ValidateSet(0, 1, 2, 3, 4)][int]$Level = 0,
                    [Parameter(Mandatory=$true)][string]$Message
                )
                $Message = $Message.Replace("`r",'').Replace("`n",' ')

                switch ($Level) {
                        0 { $Status = 'Info'      ;$FGColor = '255;255;255' } #White
                        1 { $Status = 'Success'   ;$FGColor = '90;220;35'   } #Green
                        2 { $Status = 'Warning'   ;$FGColor = '250;210;20'  } #Yellow
                        3 { $Status = 'Error'     ;$FGColor = '220;20;20'   } #Red
                        4 { $Status = 'Highlight' ;$FGColor = '200;200;200' } #Gray
                }
                
                if ($Level -eq 4) {
                    Write-Host "`e[38;2;100;100;100m$((Get-Date).ToString()) `e`e[38;2;$($FGColor)m$Status`e[0m`t`e[38;2;70;170;255m$Message`e"
                }
                else {
                    Write-Host "`e[38;2;100;100;100m$((Get-Date).ToString()) `e`e[38;2;$($FGColor)m$Status`e[0m`t$Message"
                }
            }

            
            $ComputerName = ($PSItem).ToUpper()
            Test-WSMan $ComputerName -ErrorAction Stop -Authentication Negotiate | Out-Null
            Write-Console -Level 1 -Message "$ComputerName - Test-WSMan"

            try {
                $Result = Invoke-Command -ComputerName $ComputerName -Authentication Negotiate -ErrorAction Stop {
                    
                    $ComputerName = (hostname).ToUpper()
                    $Sofwares = @()
                    $Sofwares += Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Sort-Object DisplayName
                    $Sofwares += Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Sort-Object DisplayName
                    #$Sofwares += Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Sort-Object DisplayName
                    
                    $x86Update = '-'
                    $x64Update = '-'
                    $x64 = 'C:\Program Files\Notepad++\uninstall.exe'
                    if (Test-Path $x64) {[datetime]$x64Update = (Get-Item $x64).LastWriteTime}
                    $x86 = 'C:\Program Files (x86)\Notepad++\uninstall.exe'
                    if (Test-Path $x86) {[datetime]$x86Update = (Get-Item $x86).LastWriteTime}
                    
                    # Look for hidden folders named "Bluetooth" i users AppData-folder, or any files in 'C:\ProgramData\USOShared'
                    # https://www.rapid7.com/blog/post/tr-chrysalis-backdoor-dive-into-lotus-blossoms-toolkit/
                    $USOSharedFiles = Get-ChildItem "C:\ProgramData\USOShared" | Where-Object {$_.PSIsContainer -eq $false} | Select-Object -ExpandProperty FullName
                    $bt = @()
                    Get-ChildItem C:\Users\ | ForEach-Object {
                        if (Test-Path "$($_.FullName)\AppData\Bluetooth") {
                            $bt += "$($_.FullName)\AppData\Bluetooth"
                        }
                    }

                    $All = Foreach ($Sofware in ($Sofwares | Where-Object {$_.DisplayName -match 'Notepad'})) {                        
                        $Obj = New-Object PSObject
                        $Obj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $ComputerName
                        $Obj | Add-Member -MemberType NoteProperty -Name DisplayName -Value $Sofware.DisplayName
                        $Obj | Add-Member -MemberType NoteProperty -Name DisplayVersion -Value $Sofware.DisplayVersion                        
                        $Obj | Add-Member -MemberType NoteProperty -Name Publisher -Value $Sofware.Publisher
                        $Obj | Add-Member -MemberType NoteProperty -Name InstallDate -Value $Sofware.InstallDate
                        $Obj | Add-Member -MemberType NoteProperty -Name Uninstaller64LastWriteTime -Value ($x64Update)
                        $Obj | Add-Member -MemberType NoteProperty -Name Uninstaller32LastWriteTime -Value ($x86Update)
                        $Obj | Add-Member -MemberType NoteProperty -Name BTFolder -Value $bt
                        $Obj | Add-Member -MemberType NoteProperty -Name USOSharedFiles -Value $USOSharedFiles
                        $Obj | Add-Member -MemberType NoteProperty -Name Error -Value ''
                        $Obj | Add-Member -MemberType NoteProperty -Name ErrorShort -Value ''
                        return $Obj
                    }
                    return $All
                }
                return $Result
            }
            catch {
                if ($_.Exception.Message -match '0x80090302') {
                    $ErrorShort = 'Invoke-Command - Negotiate authentication: The request is not supported'
                    Write-Console -Level 3 -Message "$ComputerName - $ErrorShort"
                }
                elseif ($_.Exception.Message -match '0x80090322') {
                    $ErrorShort = 'Invoke-Command - Negotiate authentication: An unknown security error occurred'
                    Write-Console -Level 3 -Message "$ComputerName - $ErrorShort"
                }
                elseif ($_.Exception.Message -match 'Access is denied') {
                    $ErrorShort = 'Invoke-Command - Access denied'
                    Write-Console -Level 2 -Message "$ComputerName - $ErrorShort"
                }
                else {
                    Write-Console -Level 3 -Message "$ComputerName - $($_.Exception.Message)"
                    $ErrorShort = '-'
                }
                $Obj = [PSCustomObject]@{
                    ComputerName = $ComputerName
                    DisplayName = '-'
                    DisplayVersion = '-'
                    Publisher = '-'
                    InstallDate = '-'
                    Uninstaller64LastWriteTime = '-'
                    Uninstaller32LastWriteTime = '-'
                    BTFolder = '-'
                    USOSharedFiles = '-'
                    Error = $_.Exception.Message
                    ErrorShort = $ErrorShort
                }
                $Obj
            }
            
        }
        catch {
            if ($_.Exception.Message -match 'accessible over the network') {                
                $ErrorShort = 'Test-WSMan - Network Connectivity Issue'
                Write-Console -Level 2 -Message "$ComputerName - $ErrorShort"
            }
            elseif ($_.Exception.Message -match 'server name cannot be resolved') {
                $ErrorShort = 'Test-WSMan - DNS Issue'
                Write-Console -Level 3 -Message "$ComputerName - $ErrorShort"
                
            }
            elseif ($_.Exception.Message -match 'different domains') {
                $ErrorShort = 'Test-WSMan - Workgroup or different domain'
                Write-Console -Level 3 -Message "$ComputerName - $ErrorShort"
                
            }
            elseif ($_.Exception.Message -match 'access is denied') {
                $ErrorShort = 'Test-WSMan - Access denied'
                Write-Console -Level 3 -Message "$ComputerName - $ErrorShort"
                
            }         
            else {
                Write-Console -Level 3 -Message "$ComputerName - Test-WSMan failed -> $(($_.Exception.Message) -replace "(</f).+$" -replace "^.+>")"
            }            
            $Obj = [PSCustomObject]@{
                ComputerName = $ComputerName
                A = $A                
                Error = "$(($_.Exception.Message) -replace "(</f).+$" -replace "^.+>")"
                ErrorShort = $ErrorShort
            }
            $Obj
            Clear-Variable Obj
        }
        Clear-Variable ComputerName
    }
    
    Write-Console -Level 0 -Message "Tested $($AllComputers.count) computers in $(($stopw.Elapsed.Minutes)) minutes and $(($stopw.Elapsed.Seconds)) seconds"    
    Write-Console -Level 0 -Message 'End'

    $Properties = @(
        'ComputerName'
        'DisplayName'
        'DisplayVersion'
        'Publisher'
        'InstallDate'
        'Uninstaller64LastWriteTime'
        'Uninstaller32LastWriteTime'
        'BTFolder'
        'USOSharedFiles'
        'Error'
        'ErrorShort'
    )

    $Results | Select-Object $Properties | Export-Csv -Path .\Get-NotePadPlusPlusVersionAndInstallDate.csv -Delimiter ';' -Encoding utf8 -Force -Confirm:$false
    Return $Results | Select-Object $Properties
}
