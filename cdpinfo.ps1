# Define output CSV file
$outputFile = "C:\ESXiHosts_NetworkInfo.csv"

# Initialize an array to store results
$networkData = @()

# Get all ESXi hosts in the vCenter
$vmHosts = Get-VMHost

# Loop through each ESXi host
foreach ($vmh in $vmHosts) {

    # Get the cluster name
    $cluster = Get-Cluster -VMHost $vmh | Select-Object -ExpandProperty Name

    # Check if the host is connected
    if ($vmh.State -ne "Connected") {
        Write-Output "Host $($vmh.Name) state is not connected, skipping."
        continue
    }

    # Get network system and network hint information
    Get-View $vmh.ID | ForEach-Object { 
        $esxname = $_.Name
        Get-View $_.ConfigManager.NetworkSystem 
    } | ForEach-Object { 
        foreach ($physnic in $_.NetworkInfo.Pnic) {
            $pnicInfo = $_.QueryNetworkHint($physnic.Device)

            # Collect CDP information
            foreach ($hint in $pnicInfo) {
                if ($hint.ConnectedSwitchPort) {
                    # Create a custom object with the relevant data
                    $networkData += $hint.ConnectedSwitchPort | Select-Object `
                        @{Name="Cluster"; Expression={$cluster}},         # Cluster Name
                        @{Name="VMHost"; Expression={$esxname}},          # ESXi Host Name
                        @{Name="VMNic"; Expression={$physnic.Device}},    # NIC Device
                        DevId, Address, PortId, HardwarePlatform          # CDP Info
                }
                else {
                    Write-Host "No CDP information available for $($physnic.Device) on $($esxname)."
                }
            }
        }
    }
}

# Export the results to a CSV file
$networkData | Export-Csv -Path $outputFile -NoTypeInformation

# Notify the user that the script has completed
Write-Output "Network information has been exported to $outputFile"
