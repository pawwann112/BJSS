# Connect to vSphere environment (replace with your vCenter details)
Connect-VIServer -Server Your-vCenter-Server -User Your-Username -Password Your-Password

# Function to retrieve VMotion events using Get-VIEventPlus
function Get-VMotionEvents {
    param(
        [DateTime]$Start = (Get-Date).AddDays(-10),  # Start date for events (last 10 days)
        [DateTime]$Finish = (Get-Date)               # End date for events (current date/time)
    )

    # Define event types to filter (vMotion and svMotion)
    $eventTypes = @("VmMigratedEvent", "VmRelocatedEvent")

    # Retrieve events using Get-VIEventPlus
    $events = Get-VIEventPlus -EventType $eventTypes -Start $Start -Finish $Finish |
              Where-Object { $_.GetType().Name -eq "VmMigratedEvent" } |  # Filter only VmMigratedEvents (vMotion and svMotion)
              Select-Object CreatedTime,                    # Timestamp
                            @{Name="VM"; Expression={ $_.VM.Name }},      # VM Name
                            @{Name="SrcVMHost"; Expression={ $_.SourceHost.Name.Split('.')[0] }}, # Source Host
                            @{Name="TgtVMHost"; Expression={ if ($_.Host.Name -ne $_.SourceHost.Name) { $_.Host.Name.Split('.')[0] } }},  # Destination Host
                            @{Name="SrcDatastore"; Expression={ $_.SourceDatastore.Name }},       # Source Datastore
                            @{Name="TgtDatastore"; Expression={ if ($_.Ds.Name -ne $_.SourceDatastore.Name) { $_.Ds.Name } }},            # Destination Datastore
                            @{Name="UserName"; Expression={ if ($_.UserName) { $_.UserName } else { "System" }}} # Initiated By (Username)
    
    # Return the filtered events
    return $events
}

# Retrieve VMotion events from the last 10 days
$vmotionEvents = Get-VMotionEvents

# Export events to CSV file
$exportPath = "C:\Path\To\Export\vmotion_events.csv"
$vmotionEvents | Export-Csv -Path $exportPath -NoTypeInformation

# Disconnect from vSphere environment
Disconnect-VIServer -Confirm:$false

Write-Host "VMotion events exported to $exportPath"
