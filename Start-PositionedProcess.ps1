function Start-PositionedProcess {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Spec,  # 形式: 表示領域WxH-モニタ基準XxY-ウィンドウサイズWxH

        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string[]]$CommandArgs
    )

    # Win32API定義
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
}
"@

    # 引数解析
    $Spec = $Spec.Trim(@("'", '"', '`'))
    if ($Spec -notmatch "^(\d+)x(\d+)-(\d+)x(\d+)-(\d+)x(\d+)$") {
        Write-Error "形式エラー: <DisplayW>x<DisplayH>-<TargetX>x<TargetY>-<WinW>x<WinH>"
        return
    }

    $dispW = [int]$matches[1]
    $dispH = [int]$matches[2]
    $targetRelX = [int]$matches[3]
    $targetRelY = [int]$matches[4]
    $winW = [int]$matches[5]
    $winH = [int]$matches[6]

    # モニタ取得
    Add-Type -AssemblyName System.Windows.Forms
    $targetScreen = [System.Windows.Forms.Screen]::AllScreens |
        Where-Object { $_.Bounds.Width -eq $dispW -and $_.Bounds.Height -eq $dispH } |
        Select-Object -First 1

    if (-not $targetScreen) {
        Write-Error "指定サイズのモニタが見つかりませんでした: ${dispW}x${dispH}"
        return
    }

    $baseX = $targetScreen.Bounds.X
    $baseY = $targetScreen.Bounds.Y
    $finalX = $baseX + $targetRelX
    $finalY = $baseY + $targetRelY

    # 起動コマンド
    $exePath = $CommandArgs[0]
    $procArgs = $CommandArgs[1..($CommandArgs.Length - 1)]
    $exeBase = [System.IO.Path]::GetFileNameWithoutExtension($exePath).ToLowerInvariant()

    # プロセス起動
    $proc = Start-Process -FilePath $exePath -ArgumentList $procArgs -PassThru
    Start-Sleep -Milliseconds 300

    # 一致プロセス探索ループ（最大5秒）
    $targetProc = $null
    for ($i = 0; $i -lt 10; $i++) {
        Start-Sleep -Milliseconds 500

        $candidates = Get-Process | Where-Object {
            $_.MainWindowHandle -ne 0 -and
            (
                ($_.Path -and
                 [System.IO.Path]::GetFileNameWithoutExtension($_.Path).ToLowerInvariant() -eq $exeBase) -or
                (
                    $exeBase -in @("cmd", "powershell", "bash") -and
                    $_.Name -like "WindowsTerminal*"
                )
            )
        }

        if ($candidates.Count -gt 0) {
            $targetProc = $candidates[0]
            break
        }
    }

    if (-not $targetProc) {
        Write-Warning "ウィンドウを持つプロセスが見つかりませんでした"
        return
    }

    # 移動とサイズ変更
    [Win32]::MoveWindow($targetProc.MainWindowHandle, $finalX, $finalY, $winW, $winH, $true) | Out-Null
    Write-Host "ウィンドウを移動しました: (${finalX},${finalY}) サイズ: ${winW}x${winH}"
}

Set-Alias spp Start-PositionedProcess
#spp 1920x480-0x0-300x200 powershell