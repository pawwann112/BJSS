# Input Parameters
param (
    [string]$vcFqdn = 'ch-sv01993.group.intra',
    [string]$vcUser = 'administrator@vs6bjss.local',
    [string]$vcPassword = 'hzZcL$fT8wGz9',
    [string]$ldapDomain = 'group.intra',
    [string]$csvFilePath,    # Path to CSV file containing list of users
    [string]$ssoGroup        # SSO group to add users to
)

# Connect to the SSO Admin Server
$ssoConnection = Connect-SsoAdminServer -Server $vcFqdn -User $vcUser -Password $vcPassword -SkipCertificateCheck

# Get the target SSO group
$targetGroup = Get-SsoGroup -Domain 'vs6bjss.local' -Name $ssoGroup -Server $ssoConnection

# Import users from CSV file
$users = Import-Csv -Path $csvFilePath

# Loop through each user in the CSV and add to the SSO group
foreach ($user in $users) {
    $userName = $user.UserName   # Assume 'UserName' is the column name in the CSV

    # Get the user from the SSO domain
    $ldapUserToAdd = Get-SsoPersonUser -Domain $ldapDomain -Name $userName -Server $ssoConnection

    # Add user to the SSO group
    if ($ldapUserToAdd) {
        $ldapUserToAdd | Add-UserToSsoGroup -TargetGroup $targetGroup
        Write-Host "Added user $userName to group $ssoGroup."
    } else {
        Write-Host "User $userName not found in domain $ldapDomain."
    }
}

# Disconnect from the SSO Admin Server
Disconnect-SsoAdminServer -Server $ssoConnection
