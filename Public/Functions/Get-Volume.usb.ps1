function Get-Volume.usb {
    [CmdletBinding()]
    param ()
    #=================================================
    #	Return
    #=================================================
    Return (Get-Volume.osd | Where-Object {$_.IsUSB -eq $true})
    #=================================================
}
