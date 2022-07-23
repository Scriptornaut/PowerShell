# This function takes a file path as an argument, and gets some forensic attributes associated with the file. I grab the MD5 and sha256 hashes along with
# file creation time, last accessed time, and last write time. 

function Get-FileForensics{
    param([string]$path_to_search, [switch]$Recurse)
    $origin = (Get-Location).Path
    Set-Location $path_to_search
    if ($Recurse) {
        $files = Get-ChildItem $path_to_search -Recurse -File -Force        
    }
    else {
        $files = Get-ChildItem $path_to_search  -File -Force      
        Write-Host $files
        }
     
    foreach($file in $files){
        #<When getting the hash, I was just trying to use the name. Instead, I used the full name wich has the full path name, and now I can get recursive file hashing!!!>#
        $file | Add-Member -NotePropertyName MD5 -NotePropertyValue (Get-FileHash $file.fullName -Algorithm MD5).Hash 
        $file | Add-Member -NotePropertyName SHA256 -NotePropertyValue (Get-FileHash $file.fullName).Hash
    }
    Set-Location $origin
    return $files | Format-Table -AutoSize Name, MD5, SHA256, LastAccessTime, CreationTime, LastWriteTime
    }
$path_to_search = Read-Host -Prompt "[*] Pass in the full path where you want hashes`n"
$recursive = Read-Host "[*] Do you want to include all subdirectories recursively? [y/N]"

if ($recursive -like 'y') {
    Get-FileForensics $path_to_search -Recurse
}
else {
    Get-FileForensics $path_to_search
}
