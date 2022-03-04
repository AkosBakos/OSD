function Copy-WinRE.wim {
    [CmdletBinding()]
    param (
        [string]$DestinationDirectory = "$env:Temp\sources",

        [string]$DestinationFileName = 'winre.wim'
    )
    #=================================================
    #	Block
    #=================================================
    Block-WinPE
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    #=================================================
    #	GetPartitionWinRE
    #=================================================
    Write-Verbose "Get-PartitionWinRE"
    $GetPartitionWinRE = Get-PartitionWinRE -ErrorAction Stop
    #$GetPartitionWinRE | Select-Object -Property * | Format-List
    
    if ($GetPartitionWinRE) {
        #=================================================
        #	Get WinrePartitionDriveLetter
        #=================================================
        if ($GetPartitionWinRE.DriveLetter) {
            $CreateNewDriveLetter = $false
            $WinrePartitionDriveLetter = $GetPartitionWinRE.DriveLetter
        }
        else {
            $CreateNewDriveLetter = $true
            $WinrePartitionDriveLetter = (68..90 | %{$L=[char]$_; if ((gdr).Name -notContains $L) {$L}})[0]
            Get-PartitionWinRE | Set-Partition -NewDriveLetter $WinrePartitionDriveLetter -Verbose
        }
        Write-Verbose "WinrePartitionDriveLetter: $WinrePartitionDriveLetter"
        #=================================================
        #	Get WinreLocationPath
        #=================================================
        $WinreLocationPath = (Get-ReAgentXml).WinreLocationPath
        Write-Verbose "WinreLocationPath: $WinreLocationPath"
        #=================================================
        #	Get WinreDirectory
        #=================================================
        $WinreDirectory = Join-Path "$($WinrePartitionDriveLetter):" -ChildPath $WinreLocationPath
        Write-Verbose "WinreDirectory: $WinreDirectory"

        if (!(Test-Path $DestinationDirectory)) {
            $null = New-Item -Path $DestinationDirectory -ItemType Directory -Force -ErrorAction SilentlyContinue
        }

        if (Test-Path "$WinreDirectory" -PathType Container -ErrorAction Ignore) {
            $WinreSource = Join-Path $WinreDirectory -ChildPath 'winre.wim'
            Write-Verbose "WinreSource: $WinreSource"

            robocopy "$WinreDirectory" "$DestinationDirectory" winre.wim /np /ndl /nfl /njh /njs
        }

        $WinreDestination = Join-Path $DestinationDirectory -ChildPath $DestinationFileName

        if ($DestinationFileName -ne 'winre.wim') {
            if (Test-Path $WinreDestination) {
                Remove-Item -Path $WinreDestination -Force -Verbose
            }
            Rename-Item -Path (Join-Path $DestinationDirectory -ChildPath 'winre.wim') -NewName $DestinationFileName -Verbose
        }
        #=================================================
        #	Remove Drive Letter
        #=================================================
        if ($CreateNewDriveLetter) {
            Remove-PartitionAccessPath -DiskNumber $GetPartitionWinRE.DiskNumber -PartitionNumber $GetPartitionWinRE.PartitionNumber -AccessPath "$($WinrePartitionDriveLetter):"
        }
        #=================================================
        #	Return WinreDestination Get-Item
        #=================================================
        if (Test-Path $WinreDestination -ErrorAction Ignore) {
            (Get-Item -Path $WinreDestination -Force).Attributes = 'Archive'
            Get-Item -Path $WinreDestination
        }
    }
}
