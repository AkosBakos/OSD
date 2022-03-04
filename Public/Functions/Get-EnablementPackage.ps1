function Get-EnablementPackage {
    [CmdletBinding()]
    param (
        [ValidateSet('21H2','21H1','20H2','1909')]
        [Alias('Build')]
        [string]$OSBuild = '21H2',

        [ValidateSet('x64','x86')]
        [string]$OSArch = 'x64'
    )
    #=================================================
    #   Import Local EnablementPackage
    #=================================================
    $Result = Get-WSUSXML -Catalog Enablement
    #=================================================
    #   Filter Compatible
    #=================================================
    $Result = $Result | `
    Where-Object {$_.UpdateArch -eq $OSArch} | `
    Where-Object {$_.UpdateBuild -eq $OSBuild}
    #=================================================
    #   Pick and Sort
    #=================================================
    $Result = $Result | Sort-Object CreationDate -Descending | Select-Object -First 1
    #=================================================
    #   Return
    #=================================================
    Return $Result
    #=================================================
}
