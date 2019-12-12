$PowerwallIPAddress = "192.168.10.215"
$NewBackupReservePercent = "20"
$PowerwallCAPath = "C:\path\to\ca.crt"

$callback = {
    param(
        $sender,
        [System.Security.Cryptography.X509Certificates.X509Certificate]$certificate,
        [System.Security.Cryptography.X509Certificates.X509Chain]$chain,
        [System.Net.Security.SslPolicyErrors]$sslPolicyErrors
    )

    # No need to retype this long type name
    $CertificateType = [System.Security.Cryptography.X509Certificates.X509Certificate2]

    # Read the CA cert from file
    $CACert = $CertificateType::CreateFromCertFile($PowerwallCAPath) -as $CertificateType

    # Add the CA cert from the file to the ExtraStore on the Chain object
    $null = $chain.ChainPolicy.ExtraStore.Add($CACert)

    # return the result of chain validation
    return $chain.Build($certificate)
}

# Assign your delegate to the ServicePointManager callback
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = $callback

#Get token
https://$PowerwallIPAddress/api/login/Basic
#Set the backup reserve
https://$PowerwallIPAddress/api/operation
@{"real_mode"="self_consumption";"backup_reserve_percent"=$NewBackupReservePercent}
#Commit the config
https://$PowerwallIPAddress/api/config/completed
#Cycle the Powerwall to make the changes take effect immediately by:
#a. Get a new token (same as step 1)
https://$PowerwallIPAddress/api/login/Basic
#b. Resume the Powerwall
https://$PowerwallIPAddress/api/sitemaster/run