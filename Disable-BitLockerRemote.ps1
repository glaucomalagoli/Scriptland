param(
    [Parameter(Mandatory = $true)]
    [string]$ComputerName,

    [Parameter(Mandatory = $false)]
    [string]$MountPoint = 'C:'
)

# Solicita credenciais para a máquina remota (conta com permissão administrativa)
$Credential = Get-Credential -Message "Informe as credenciais para $ComputerName"

Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
    param($RemoteMountPoint)

    Disable-BitLocker -MountPoint $RemoteMountPoint
} -ArgumentList $MountPoint
