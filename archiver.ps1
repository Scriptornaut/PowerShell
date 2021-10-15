# This script will help users backup specific directories directory
# List the contents of a directory as options in a menu

Clear-Host
Write-Host "Welcome to the Archive & Backup Utlity`nHere is a list of items to back up"

pause 
#Read-Host -Prompt "Press Enter to Continue"

$counter = 0
$list = Get-ChildItem -Name C:\Users\Marc
$destfile = "C:\Users\Public\backup_$selection.zip"
$destpath = "C:\Users\Public"
$dirs = @()
foreach ($item in $list)
    {
        Write-Host "$counter. $item"
        $counter += 1
        $dirs += $item
    }
$choice = Read-Host -Prompt "Choose a number "
$selection = $dirs[$choice]
Write-Host -ForegroundColor yellow "[*] You picked $choice, $selection . Here is what is in it:`n"
Get-ChildItem  -Path C:\Users\Marc\$selection
Pause
Write-Host -ForegroundColor Green "[*] Continuing will create a backup file at this path`n$destpath"`n
Pause

if (Test-Path -Path $destfile){
    Write-Host -ForegroundColor Yellow "[!] An archive already exists. Do you want to overwrite it? [y/n]"
    $option = Read-Host "> "
    if ($option -eq "y"){
        Write-Host -ForegroundColor Green "[*] Overwriting Archive, please wait ..."
        Start-Sleep 2
        Compress-Archive -Path C:\Users\Marc\$selection -Update -DestinationPath $destfile
        $archive = Get-ChildItem "C:\Users\Public\backup_$selection.zip"
        Write-Host -ForegroundColor Green "[*] Here's your archived file $archive"
        }
    elseif ($option -eq "n") {
        Write-Host -ForegroundColor Blue "[*] Have a nice day. "
    }
}
else {
    Write-Host -ForegroundColor Green "[*] Creating Archive, please wait ..."
    Start-Sleep -Seconds 5
    Compress-Archive -Path C:\Users\Marc\$selection -DestinationPath $destfile
    $archive = Get-ChildItem $destfile
    Write-Host -ForegroundColor Green "[*] Here's your archived file $archive"
        
}
exit