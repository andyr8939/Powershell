# This script deploys Winlogbeat, part of the ELK Stack to each of my Wintel servers for centralized log monitoring.

# Give a credential enough to connect to AD and also with permissions on the servers you want to deploy to.
$mycred = Get-Credential
# You don't need to specify a DC here if you are joined to domain.  I included this as I am not always a domain member at client sites I work at.
$adserver = "enter a DC name to search"
$memberservers = "OU=Member Servers,DC=domain,DC=local"
# This is the servers you want to deploy the agent to
$servers = (Get-ADComputer -SearchBase $memberservers -Filter { OperatingSystem -like '*Windows Server 2008*' } -Credential $mycred -Server $adserver).Name
# Adjust path to match where you have the client
$winlogbeatagentpath = "\\fileserver\software\elk-stack\winlogbeat"
New-PSDrive -Name Software -PSProvider FileSystem -Root $winlogbeatagentpath -Credential $mycred

foreach ($item in $servers)
{
    $mysession = New-PSSession $item -Credential $mycred
    Copy-Item -Path Software:\ -ToSession $mysession -Destination "C:\Program Files\" -Recurse -Force
    Remove-PSSession $mysession
}

# Now do the install of the agent.  Get the original execution policy, then reset it and then flip it back.
# Not the cleanest way but had issues installing the agent with the bypass flag.

Invoke-Command -ComputerName $servers -ScriptBlock {
    $origexecpolicy = Get-ExecutionPolicy ;
    Set-ExecutionPolicy Unrestricted ;
    Set-Location -Path 'C:\Program Files\Winlogbeat' ;
    .\install-service-winlogbeat.ps1 ;
    Set-ExecutionPolicy $origexecpolicy ;
    Start-Service winlogbeat } -Credential $mycred

Invoke-Command -ComputerName $servers -ScriptBlock { Get-Service winlogbeat | Restart-Service -PassThru} -Credential $mycred

