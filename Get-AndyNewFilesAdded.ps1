# This script alerts you via email if a file has been added to a location in the last x amount of time defined in the $dateforemail variable.
# I used this for a SFTP site to alert a team of new data drops and was run as a scheduled tasks every hour.

# Set the server location to monitor
$Location = '\\servername\share\'

# Change to this location
Set-Location $Location

# Define how long to check back for files.  Base your scheduled tasks around this.  
# Note for future - Add an automated task schedule here.
$dateforemail=(Get-Date).AddHours(-1)

# Get the file list from the folder and convert to html for email

$filelist= (Get-ChildItem | select -Property name,lastwritetime,length | where -property lastwritetime -GT $dateforemail | sort -Property Name -Descending | ConvertTo-Html)

# Define email headers
$emailreceiptient="email@me.com"
$sitename="sitename"
$SmtpServer="email servrer name"
$youremail="me@this.com"
$emailbody = "
<p style='font-family:calibri'>This is an automated alert to you let you know that a new file has been uploaded to the $sitename in the last hour.</P>
<p></p>
<p style='font-family:calibri'>The file details are:-</p>
<p></p>
<p style='font-family:calibri'>$filelist</p>
<p></p>
<p style='font-family:calibri'>You can access it at - $Location</p>
"

# Create the email if files have been added

if (test-path * -NewerThan (Get-Date).AddHours(-1)) {
    Send-MailMessage -To $emailreceiptient -Subject "New SFTP File Found" -Body $emailbody -SmtpServer $SmtpServer -From $youremail -BodyAsHtml 
}
