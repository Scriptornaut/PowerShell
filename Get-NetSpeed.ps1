# The ultimate goal of this script is to help the scheduling and automation of bandwith tests over a set period of time. 
# This script depends on the ookla speedtest cli tool for Windows
# Not all of the functions are functional. I'm posting before complete so others can review the work already done. 
# The menu isn't fully developed. I uncomment lines as necessary for testing. The toughest part of this script has been working with the scheduled tasks. 

Clear-Host
function Get-Menu {
    Write-Host "Welcome to the SpeedTest Menu"
    Write-Host "Choose From the Options Below"`n
    Write-Host `t"1. Download and install the latest Ookla Speedtest Utility."
    Write-Host `t"2. Run a single speed test."
    Write-Host `t"3. Setup a reccuring speedtest."`n
    $choice = Read-Host "Enter a number > "
    if ($choice -eq '1') {
        Get-Ookla}
    elseif ($choice -eq '2') {
        Set-Location ~\SpeedTestFiles
        .\speedtest.exe     
        }
    elseif ($choice -eq '3') {
        Set-Schedule
        #Get-Speed
    }
}
function Get-Speed {
    Write-Host -ForegroundColor Yellow "[*] Speed Test in progress, please wait..."
    $result_data = ~\SpeedTestFiles\speedtest.exe -u Mbps -p yes -f json-pretty
    $results = $result_data |ConvertFrom-Json
    $dl_speed = ([math]::Truncate($results.download.bandwidth / 125000))
    $ul_speed = ([math]::Truncate($results.upload.bandwidth / 125000))
   # $dl_speed = $dl_speed.ToString() + " Mbps"
   # $ul_speed = $ul_speed.ToString() + " Mbps"
    
    $resultArray = @()
    
    $speedinfo = [PSCustomObject]@{
        
        "Date" = Get-Date -Format "MM/dd/yy"
        "Time" = Get-Date -Format "HH:mm"
        "Downlad Speed" = $dl_speed
        "Upload Speed" = $ul_speed
        "Packet Loss" = $results.packetLoss
        "Ping" = $results.ping.latency
        "Result Link" = $results.result.url
        }
    $resultArray += $speedinfo
    $csvFile = "$HOME\SpeedTestFiles\results.csv"            
	if (Test-Path -Path $csvFile) {
        Write-Host "[*] Updating $csvFile.."
        Start-Sleep 2
        return $resultArray |Export-Csv $csvFile -Append
     #Import-Csv "$HOME\SpeedTestFiles\results.csv" |Select-Object -Last 1 |Format-Table
    }else {
        Write-Host "[*] Creating a csv file in $HOME\SpeedTestFiles\results.csv"
        New-Item $csvFile
        return $resultArray |Export-Csv $csvFile
        #Import-Csv "$HOME\SpeedTestFiles\results.csv" |Select-Object -Last 1 |Format-Table
    }
$display_result = Import-Csv "$HOME\SpeedTestFiles\results.csv" |Select-Object -Last 1 |Format-Table
Write-Host "[*] Loading Results... "
Start-Sleep 3
$display_result
}
function Get-Ookla {
    $links = Invoke-WebRequest https://www.speedtest.net/apps/cli |Select-Object -Property Links
    $urls = $links.Links.outerHTML
    $urls2 = $urls |select-string href
    $win_dl = $urls2 |Select-Object -Property Line |Select-String 'win64'
    $dl_link = $win_dl.ToString() |  ForEach-Object {$_.split('"')[3]}
    Write-Host -ForegroundColor Yellow "[*] The download link is"`n`t$dl_link
    Start-Sleep 2
    Write-Host -ForegroundColor Yellow "[*] Downloading ..."
    Invoke-WebRequest -Uri $dl_link -OutFile ~\speedtest.zip
    Start-Sleep 1
    Write-host -ForegroundColor Green `n"[*] Download Complete"
    Start-Sleep 1
    Write-Host -ForegroundColor Yellow "[*] Decompressing Files... "
    Expand-Archive ~\speedtest.zip SpeedTestFiles
    Remove-Item ~\speedtest.zip
    Set-Location ~\SpeedTestFiles
    Clear-Host
    $version = .\speedtest.exe --version  
    Write-Host -ForegroundColor Green "[*] Version Info Below"`n
    $version
}
function Set-Schedule {
 
 #Build a better scheduled task. Ask for user input throughout.
 # Ask if they want the task to run whether logged in or not
 # Ask "How many days do you want to collect data?"
 # Ask "How frequent?" Offer options (Hourly, or specified hour interval i.e. 6)
 # Ask if they want to modify the schedule using Task Scheduler
 # I'll need to figure out how to call this script with an argument that runs the Get-Speed function.
 
    
    $newTaskAction = @{
        Execute = 'powershell.exe'
	#The file argument below is for testing only. It is a simple hello world script that logs a string to a file
        Argument = "-File $HOME\SpeedTestFiles\hello.ps1"
    }
    
    $newTaskTrigger = @{
        Daily = $true
        At = (Read-Host "What time of day do you want to start testing? ")
        RepetitionDuration = (New-TimeSpan -Days 3)
    }
        
    $registerTask = @{
        TaskName = "WriteHello"
        Action = New-ScheduledTaskAction @newTaskAction
        Trigger = New-ScheduledTaskTrigger @newTaskTrigger
        Description = "Testing Splat Trigger Hello World"
    }
    
    Register-ScheduledTask @registerTask
}
Get-Menu

exit 
