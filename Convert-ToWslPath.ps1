function Convert-ToWslPath {
    param($winPath)
    $path = $winPath -replace "^[A-Za-z]:", { "/mnt/$($_.Value[0].ToLower())" }
    return $path -replace '\\','/'
}
Set-Alias 2wsl Convert-ToWslPath