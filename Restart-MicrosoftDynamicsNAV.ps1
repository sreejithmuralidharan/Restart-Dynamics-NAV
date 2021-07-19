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

    $proc =get-counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 5
    $cpu=($proc.readings -split ":")[-1]
    $cpu = ([Math]::Round($cpu, 2))
    if ($cpu -gt 80) {
        restart_nav('API')
        $msg = "CPU threshold reached $($cpu)%, NAV instance restarted"
        write_event_log($msg)
    }else{
        Write-Host "CPU within threshold $($cpu)%."
    }   
}

check_cpu_usage
