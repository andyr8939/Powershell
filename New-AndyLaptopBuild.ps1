# I use this script on new laptops deployed from base images.
# It get the serial number of the machine, appends this to the machine to form a name, joins to domain and sets WSUS to talk.
# Have to run this script after each reboot.  For future get this to auto run and continue automatically.

#Define all the variables we are going to work with

$serial = gwmi win32_bios | select -ExpandProperty SerialNumber
$manufacturer = gwmi win32_bios | select -ExpandProperty Manufacturer
$currentdomain = gwmi win32_computersystem | select -ExpandProperty Domain
$desireddomain = "set domain name here"
$currenthostname = (gwmi win32_computersystem).Name.Trim()

# Set machinename if its a Lenovo
if ($manufacturer -like "Lenovo*")
{
    $make = "Lenovo"
    $desiredhostname = $make + "-" + $serial
}

# Set machinename if its a HP
if ($manufacturer -like "HP*" -or "Hewlett*")
{
    $make = "HP"
    $desiredhostname = $make + "-" + $serial
}


# Check hostname and if not in the desired format then rename it
if ($currenthostname -ne $desiredhostname)
{
    Rename-Computer $desiredhostname -Restart
}


# Check domain joined status and join if not on domain
if ($currentdomain -ne $desireddomain)
{
    Add-Computer -DomainName $desireddomain -Credential (Get-Credential) -Restart
}


# Clean up WSUS duplicate SIDs and force re-auth and update checks
Stop-Service wuauserv
Remove-ItemProperty -Path “HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate” -Name "AccountDomainSid" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
Remove-ItemProperty -Path “HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate” -Name "PingID" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
Remove-ItemProperty -Path “HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate” -Name "SUSClientID" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
Remove-ItemProperty -Path “HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate” -Name "SusClientIDValidation" -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
Start-Service wuauserv
wuauclt.exe /resetauthorization /detectnow 