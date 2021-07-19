 # Function to write to windows event log
function write_event_log($msg) {
$AppName = 'Grays CPU Monitor'
        If ([System.Diagnostics.EventLog]::SourceExists($AppName) -eq $False) {
        New-EventLog -LogName Application -Source $AppName
        }
        Write-EventLog -LogName "Application" -Source $AppName -EventID 3001 -EntryType Information -Message $msg 
}


# Function to restart Microsoft Dynamics NAV Instance
function restart_nav($instanceName) {
    import-module 'C:\Program Files\Microsoft Dynamics NAV\100\Service\Microsoft.Dynamics.Nav.Management.dll'
    $ServerInstances = $instanceName
    $ServerInstances | Set-NAVServerInstance -Stop
    $ServerInstances | Set-NAVServerInstance -Start
}


# Function to check CPU usage
function check_cpu_usage(){

    $Processor = (Get-WmiObject -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average
    echo $Processor

    $Processor = Get-Counter '\Processor(*)\% Processor Time' |
        select -expand CounterSamples | 
        where{$_.InstanceName -eq '_total' -and $_.CookedValue -gt 80} |
        ForEach{Write-Host $_.CookedValue -fore Red}
    if ($Processor -gt 80) {
        restart_nav('API')
        $msg = "CPU threshold reached $($Processor), NAV instance restarted"
    }   
    $msg = "CPU threshold reached $($Processor)"
    write_event_log($msg)
        
}

check_cpu_usage
 
