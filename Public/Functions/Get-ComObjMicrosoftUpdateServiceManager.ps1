function Get-ComObjMicrosoftUpdateServiceManager {
    [CmdletBinding()]
    param ()

    Return (New-Object -ComObject Microsoft.Update.ServiceManager).Services
}
