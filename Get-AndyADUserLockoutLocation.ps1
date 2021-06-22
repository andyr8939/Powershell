<#
.SYNOPSIS
Find out where an Active Directory User Account is being locked out from
.DESCRIPTION
Get-ADUserLockoutLocation will search through Domain Controller Security logs to identify a specific users last location location
as well as where their last incorrect password came from to help idenfity the location
Created by Andy Roberts (andyr8939@gmail.com)
.PARAMETER username
The username of the user you are searching for.  Mandatory
.PARAMETER dcou
The OU in your Active Directory that contains your domain controllers.
Haven't figured out how to dynamically query this yet.  Change this!
.PARAMETER adserver
A domain controller to query.  
Default - Your current logon server
.PARAMETER failedpasswords
How manny failed locations to search against.
Default - 5
.PARAMETER credential
Elevated Credentials to search against DC Event Logs.  Only needed if account is different to current.
.PARAMETER failedpassid
EventID for the Failed Password attempt.
.PARAMETER lockoutid
EventID for the Account Lockout.
.EXAMPLE
Get-ADUserLockoutLocation -SearchName username Andy -AdServer dc1 -credential (Get-Credential)
This searchs for user Andy, using credentials that I'm prompted for with my DC being dc1
.EXAMPLE
Get-ADUserLockoutLocation -SearchName username Andy
This searchs for user Andy, using your current logon credentials and using your current logon server as the DC.
#>
[CmdletBinding()]
param (
[Parameter(Mandatory=$True,HelpMessage="Enter a Username to search on")]
[string]$username,

[Parameter(HelpMessage="Enter a DC OU to search")]
[string]$dcou = "OU=Domain Controllers,DC=changeme,DC=changeme",

[Parameter(HelpMessage="Enter an Domain Controller Name to search")]
[string]$adserver = $env:LOGONSERVER.Trim("\\"),

[Parameter(HelpMessage="Number of failed passwords to search")]
[int]$failedpasswords = 5,

[Parameter(HelpMessage="Enter your credentials if different than current")]
[System.Management.Automation.PSCredential]
[System.Management.Automation.Credential()]
$credential = [System.Management.Automation.PSCredential]::Empty

#[Parameter(HelpMessage="EventID for Failed Password")]
#[int]$failedpassid = "4771",

#[Parameter(HelpMessage="EventID for Account Lockout")]
#[int]$lockoutid = "4740"
)


# Get failed attempts

Write-Host ""
Write-Host "These systems are where the last" $failedpasswords "failed password attempts came from"

if ($credential -ne [System.Management.Automation.PSCredential]::Empty)
{
    # Get DCs for the domain
    # Get only 2008 and higher DCs due to lack of powershell on 2003
    $dcs = (Get-ADComputer -SearchBase $dcou -Filter { OperatingSystem -notlike '*Windows Server 2003' } -Credential $credential -Server $adserver).Name
    Invoke-command -ComputerName $dcs {get-eventlog Security -EntryType FailureAudit -InstanceId 4771 -ErrorAction SilentlyContinue -WarningAction SilentlyContinue} -Credential $credential | 
    where {$_.ReplacementStrings[0] -like $username} | 
        select @{l="userid";e={$_.ReplacementStrings[0]}},@{l="ip";e={$_.ReplacementStrings[6]}},Index,EventID,TimeWritten,@{l="Domain Controller";e={$_.PSComputerName}} -First $failedpasswords | 
            FT -AutoSize
}
else
{
    # Get DCs for the domain
    # Get only 2008 and higher DCs due to lack of powershell on 2003
    $dcs = (Get-ADComputer -SearchBase $dcou -Filter { OperatingSystem -notlike '*Windows Server 2003' } -Server $adserver).Name
    Invoke-command -ComputerName $dcs {get-eventlog Security -EntryType FailureAudit -InstanceId 4771 -ErrorAction SilentlyContinue -WarningAction SilentlyContinue} | 
    where {$_.ReplacementStrings[0] -like $username} | 
        select @{l="userid";e={$_.ReplacementStrings[0]}},@{l="ip";e={$_.ReplacementStrings[6]}},Index,EventID,TimeWritten,@{l="Domain Controller";e={$_.PSComputerName}} -First $failedpasswords | 
            FT -AutoSize
}


# Get locked out status

Write-Host "This is the system where the user account lockout came from"


if ($credential -ne [System.Management.Automation.PSCredential]::Empty)
{
    Invoke-Command -ComputerName $dcs {get-eventlog Security -EntryType SuccessAudit -InstanceId 4740 -Newest 1 -ErrorAction SilentlyContinue -WarningAction SilentlyContinue} -Credential $credential |
    where {$_.ReplacementStrings[0] -like $username} | 
        select @{l="Username";e={$_.ReplacementStrings[0]}},@{l="Locked Out System";e={$_.ReplacementStrings[1]}},@{l="Lockout Time";e={$_.TimeWritten}},@{l="Domain Controller";e={$_.PSComputerName}} | 
            FT -AutoSize
}
else
{
    Invoke-Command -ComputerName $dcs {get-eventlog Security -EntryType SuccessAudit -InstanceId 4740 -Newest 1 -ErrorAction SilentlyContinue -WarningAction SilentlyContinue} |
    where {$_.ReplacementStrings[0] -like $username} |
        select @{l="Username";e={$_.ReplacementStrings[0]}},@{l="Locked Out System";e={$_.ReplacementStrings[1]}},@{l="Lockout Time";e={$_.TimeWritten}},@{l="Domain Controller";e={$_.PSComputerName}} | 
            FT -AutoSize
}
