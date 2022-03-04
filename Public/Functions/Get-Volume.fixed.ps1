function Get-Volume.fixed {
    [CmdletBinding()]
    param ()
    #=================================================
    #	Return
    #=================================================
    Return (Get-Volume.osd | Where-Object {$_.IsUSB -eq $false})
    #=================================================
}
