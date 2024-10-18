# Connect to vSphere environment (replace with your vCenter details)
Connect-VIServer -Server Your-vCenter-Server -User Your-Username -Password Your-Password

# List of VMs to migrate (replace with actual VM names)
$vmList = @("VM1", "VM2", "VM3")

# Target ESXi host for vMotion (replace with the actual ESXi host name)
$targetHost = Get-VMHost -Name "Target-ESXi-Host"

# Function to perform vMotion for a given VM to the target host
function Migrate-VMToHost {
    param(
        [string]$vmName,   # VM name to be migrated
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHostImpl]$destinationHost  # Destination ESXi host
    )
    
    # Get the VM object
    $vm = Get-VM -Name $vmName

    if ($vm) {
        try {
            # Initiate vMotion to the target host
            Write-Host "Migrating $vmName to $($destinationHost.Name)..."
            Move-VM -VM $vm -Destination $destinationHost -Confirm:$false
            Write-Host "Migration of $vmName completed successfully."
        } catch {
            Write-Host "Error migrating $vmName: $_"
        }
    } else {
        Write-Host "VM $vmName not found."
    }
}

# Loop through each VM and initiate the migration
foreach ($vmName in $vmList) {
    Migrate-VMToHost -vmName $vmName -destinationHost $targetHost
}

# Disconnect from vSphere environment
Disconnect-VIServer -Confirm:$false
