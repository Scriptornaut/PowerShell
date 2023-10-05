# This script will take json files and turn them into CSV files for analysis

# Initialize an array for later use
$resultArray = @()

# Assign the json file as a variable
#$workingFile = Read-Host "Paste in the full path to the json file you want to parse... "

$workingFile = "C:\Users\Marc\Documents\bethany_json\security_and_login_information\account_activity.json"

#Convert the JSON file to a PowerShell object
$data0 = Get-Content $workingFile |ConvertFrom-Json

#Different json files have different NoteProperty Names. The line below accounts for varriance. 
$value = ($data0 |Get-Member -MemberType NoteProperty).name

 

$data1 = $data0.$value

# Need a more accurate way to convert from epoch to human readable.

    foreach ($line in $data1) 
    {
        $line.timestamp = (([System.DateTimeOffset]::FromUnixTimeSeconds($line.timestamp)).DateTime).ToString()
        $resultArray += $line       
    }
    $newArray = @()

    foreach ($record in $resultArray)
        { $eventInfo = [PSCustomObject]@{
             "TimeStamp" = $record.timestamp
             "Event" = $record.action 
             "IP Address" = $record.ip_address
             "City" = $record.city
             "Device" = $record.user_agent
             "Cookie" = $record.datr_cookie 
             }
        $newArray += $eventInfo
        }

    $csvFile = "$HOME\Desktop\results.csv"            
	if (Test-Path -Path $csvFile) {
        Write-Host "[*] Updating $csvFile.."
        Start-Sleep 2
        return $newArray |Export-Csv $csvFile -Append
        }
    else {
        Write-Host "[*] Creating a csv file in $HOME\Desktop\results.csv"
        New-Item $csvFile
        return $newArray |Export-Csv $csvFile
        }
