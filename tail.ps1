function tail {
    param (
        [Parameter(Mandatory = $true)]
        [string]$StrPath
    )
    Get-Content -Path $StrPath -Wait -Tail 10 -Encoding utf8
}
