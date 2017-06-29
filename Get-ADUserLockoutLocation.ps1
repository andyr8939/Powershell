# Created by Andy Roberts (andyr8939@gmail.com)
# This script was created due to dealing with users who constantly lock themselves out when in a VDI environment by leaving open sessions.
# It will query all available DC event logs looking for the last set of bad passwords attempts and also the last locked out location reported
# on each DC for that user, allowing you to find where they are getting locked from.

# Get the username you want to search for
$searchname = Read-Host -Prompt "What username do you need?"

# Until I can figure out how to dynamically search for the OU based on domain if you are not domain joined, this has to be specified
$dcou = "OU=Domain Controllers,DC=changeme,DC=changme"

# Get AD server if not joined to that domain.  If bypassed with enter take the local value, searching on 0 is because its zero length string
# and then trim out the \\ so it can be used in the Get-ADComputer section
Write-Host "If you are quering a domain you are not joined to, enter a DC name below.  Otherwise just press enter to take your local DC."
$adserver = Read-Host -Prompt "Enter DC name"
if ($adserver -le 0 )
{    $env:LOGONSERVER.Trim("\\")  }

# Get Credentials to access the event logs on DCs.  You won't need this if domain joined, so can also remove the credential checks elsewhere
# but I need to jump arond domains so have left this in.
Write-Host "Enter your domain credentials to query DC event logs"
$mycreds = Get-Credential

# Get DCs for the domain
# Get only 2008 and higher DCs due to lack of powershell on 2003
$dcs = (Get-ADComputer -SearchBase $dcou -Filter { OperatingSystem -notlike '*Windows Server 2003' } -Credential $mycreds -Server $adserver).Name

# Specify the amount of failed password attempts you want to seach for in the event logs
$failedpasswords = 5

# Get failed attempts

Write-Host ""
Write-Host "These systems are where the last" $failedpasswords "failed password attempts came from"
Invoke-command -ComputerName $dcs {get-eventlog Security -EntryType FailureAudit -InstanceId 4771 -ErrorAction SilentlyContinue -WarningAction SilentlyContinue} -Credential $mycreds | 
    where {$_.ReplacementStrings[0] -like $searchname} | 
        select @{l="userid";e={$_.ReplacementStrings[0]}},@{l="ip";e={$_.ReplacementStrings[6]}},Index,EventID,TimeWritten,@{l="Domain Controller";e={$_.PSComputerName}} -First $failedpasswords | 
            FT -AutoSize


# Get locked out status

Write-Host "This is the system where the user account lockout came from"
Invoke-Command -ComputerName $dcs {get-eventlog Security -EntryType SuccessAudit -InstanceId 4740 -Newest 1 -ErrorAction SilentlyContinue -WarningAction SilentlyContinue} -Credential $mycreds | 
    select @{l="Username";e={$_.ReplacementStrings[0]}},@{l="Locked Out System";e={$_.ReplacementStrings[1]}},@{l="Lockout Time";e={$_.TimeWritten}},@{l="Domain Controller";e={$_.PSComputerName}} | 
        FT -AutoSize

