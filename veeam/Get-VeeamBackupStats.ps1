# Created by Andy Roberts (andyr8939@gmail.com)
#
# This script was created so I can export Veeam backup stats to an Excel file which was required by an internal reporting process.
# This was then picked up by another software agent running on the Veeam VM and transfered outw
# I run this as a scheduled task every day at 7am so all the backups have completed by this time, but you could always run it as a post Veeam backup task.

# Add the VeeamPSSnapIn
Add-PSSnapin VeeamPSSnapIn

# Declare an array to collect our result objects
$resultsarray =@()

# Get the Veeam Backup Jobs
$Jobs = Get-VBRJob

# Cycle through the backup jobs
foreach ($Job in $Jobs) {
    # Get the Last Backup Session
	$LastSession = $Job.FindLastSession()
    # Now get the invididual tasks within that Session
	$TaskSessions = $LastSession | Get-VBRTaskSession
	foreach ($vm in $TaskSessions) { 
            # Create a new custom object to hold our result.
            $jobObject = new-object PSObject
            # Now put each item you need into the object
            $jobObject | add-member -membertype NoteProperty -name "VM ID" -Value ($VMID = $vm.ID)
            $jobObject | add-member -membertype NoteProperty -name "Job ID" -Value ($JobID = $vm.JobSessId)
            $jobObject | add-member -membertype NoteProperty -name "Job Name" -Value ($JobName = $vm.Jobname)
            $jobObject | add-member -membertype NoteProperty -name "VM Name" -Value ($VMName = $vm.Name)
            $jobObject | add-member -membertype NoteProperty -name "Status" -Value ($Status = $vm.Info.Status)
            $jobObject | add-member -membertype NoteProperty -name "Start Time" -Value ($StartTime = $vm.JobSess.CreationTime)
            $jobObject | add-member -membertype NoteProperty -name "End Time" -Value ($EndTime = $vm.JobSess.EndTime)
            $jobObject | add-member -membertype NoteProperty -name "Elapsed Time - Seconds" -Value ($ElapsedTime = (New-TimeSpan -Start $vm.JobSess.CreationTime -End $vm.JobSess.EndTime).Seconds)
            $jobObject | add-member -membertype NoteProperty -name "Backup Job Size - Gb" -Value ($BackupSize = [math]::Round((($vm.JobSess.BackupStats.BackupSize) / 1GB),2))
            $jobObject | add-member -membertype NoteProperty -name "Backup Job Data Size - Gb" -Value ($BackupDataSize = [math]::Round((($vm.JobSess.BackupStats.DataSize) / 1GB),2))
            $jobObject | add-member -membertype NoteProperty -name "Backup Job DeDupe Ratio - %" -Value ($BackupDeDupSize = $vm.JobSess.BackupStats.DeDupRatio)
	
# Save the current $jobObject by appending it to $resultsArray
$resultsarray += $jobObject
    }
}
# Export the array to a CSV
$resultsarray | Export-csv "$tempdir\veeam.csv" –notypeinformation