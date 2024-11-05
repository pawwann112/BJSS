$vcFqdn = 'ch-sv01993.group.intra'
$vcUser = 'administrator@vs6bjss.local'
$vcPassword = 'hzZcL$fT8wGz9'
$ldapDomain = 'group.intra'
$ldapUser = 'adm_arsi'
$ssoDomain = 'vs6bjss.local'
$ssoGroup = "BJSS-VM-Power-User-DLP-INTERNATIONAL"

$ssoConnection = Connect-SsoAdminServer -Server $vcFqdn -User $vcUser -Password $vcPassword -SkipCertificateCheck
$targetGroup = Get-SsoGroup -Domain $ssoDomain -Name $ssoGroup -Server $ssoConnection
$ldapUserToAdd = Get-SsoPersonUser -Domain $ldapDomain -Name $ldapUser -Server $ssoConnection
$ldapUserToAdd | Add-UserToSsoGroup -TargetGroup $targetGroup
