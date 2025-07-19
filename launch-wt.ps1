# launch-wt.ps1 の中身
. "C:\Users\nu\ps\Start-PositionedProcess.ps1"
Start-PositionedProcess '1920x480-0x0-1620x440' wt.exe -p "Windows PowerShell"
#-d "K:\wsl" 
wt.exe -p "Ubuntu-24.04"
