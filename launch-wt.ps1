. "C:\Users\nu\ps\Start-PositionedProcess.ps1"
Start-PositionedProcess '1920x480-0x0-1620x440' wt.exe -p "Windows PowerShell"
#-d "K:\wsl" 
Start-Sleep -Milliseconds 4000
wt.exe -p "Ubuntu-24.04"
Start-Sleep -Milliseconds 4000
Start-PositionedProcess '2560x1440-0x0-900x1440' T:\nny\src\FullScreenImageApp\Rel\FullScreenImageApp.exe

#Start-PositionedProcess '2560x1440-2000x0-560x1440' 
