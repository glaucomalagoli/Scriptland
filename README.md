# Scriptland

-DisableNLA
  Sets the default or user specified port number for Remote Desktop connections. Enables firewall rule for inbound access to the port.
  
-DisableWindowsUpdate
  Disable Automatic Updates through Windows Update.

-EnableAdminAccount
  Checks if the local Administrator account is disabled, and if so enables it.

-EnableRemotePS
   Configure the machine to enable remote PowerShell.

-EnableWindowsUpdate
    Enable Automatic Updates through Windows Update.

-RDPSettings_CheckDefault_Policies
    Checks registry settings and domain policy settings. Suggests policy actions if machine is part of a domain or modifies the settings to default values.
    
-ResetRDPCert
    Removes the SSL certificate tied to the RDP listener and restores the RDP listener security to default. Use this script if you see any issues with the certificate.
    
-SetRDPPort
    Sets the default or user specified port number for Remote Desktop connections. Enables firewall rule for inbound access to the port.
