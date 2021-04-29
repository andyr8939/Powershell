# Created by Andy Roberts (andyr8939@gmail.com)
#
# This script was created so I knew which backups tapes needed to be removed from our autoloader each day, ready to be sent off-site for secure storage.
# Without this I had to manually open Backup Exec and qeury the media slots for most recently used media.
# This was testing on Backup Exec 2014 running on Windows Server 2012 with a HP 1/8 G2 LT05 Autoloader

# Define contacts
$recipient = enter receipient email here
$sender = enter sender email address here
$subject = "Enter email subject header"
$smtpserver = enter your email server here

# Import BEMCLI Modules
Import-Module "D:\Program Files\Symantec\Backup Exec\Modules\BEMCLI"

# If you run this job automatically after a backup job completes, you need to make it wait for the media to be put back into the slots, otherwise it doesn't show.
# If you however are running this as a scheduled task then leave this commented out.
#Start-Sleep 60

# Get the tapes most recently used, set at 72hrs to cover weekend backups
$lastdate=(get-date).AddHours(-72)

# Get the current media in the library
Get-BEMedia -MediaVault "Online Tape Media"

# Identity which media in the library was allocated in the last time period
$mediatoremove = Get-BEMedia -MediaVault "Online Tape Media" | where {$_.AllocatedDate -gt $lastdate} 

#Ceate the mail body by defining a variable of looping through all the meida found and format as a string so can be used in email.
$body=@"
The following are the tapes to be removed today.
$($mediatoremove | foreach { Get-BERoboticLibrarySlot -Media $_.Name } | select Name, Media | Sort-Object Name | Out-String)
"@

#Send the mail
Send-MailMessage -To $recipient -Subject $subject -From $sender -Body $body -SmtpServer $smtpserver