
param (
	[Parameter(Mandatory = $True)]
	[string]$Action
	)
	
	
######################################################################################################################################################


# Identify Current User And Set Variable
#Get logged on User
$Loggedon = Get-WmiObject -ComputerName $env:COMPUTERNAME -Class Win32_Computersystem | Select-Object UserName
#Split User and Domain
$DomainName, $CurrentUser = $Loggedon.Username.split('\', 2)
Write-Host $DomainName
Write-Host $CurrentUser
######################################################################################################################################################


function Clear-BrowserCaches
{
	#"-------------------"
	# Current User Temp Files
	#"-------------------"	
	
	
	
	#Clear Mozilla Firefox Cache
	
	Remove-Item -path C:\Users\$CurrentUser\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache\* -Recurse -Force -EA SilentlyContinue | Out-Null
	Remove-Item -path C:\Users\$CurrentUser\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache\*.* -Recurse -Force -EA SilentlyContinue | Out-Null
	Remove-Item -path C:\Users\$CurrentUser\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache2\entries\*.* -Recurse -Force -EA SilentlyContinue | Out-Null
	Remove-Item -path C:\Users\$CurrentUser\AppData\Local\Mozilla\Firefox\Profiles\*.default\thumbnails\* -Recurse -Force -EA SilentlyContinue | Out-Null
	Remove-Item -path C:\Users\$CurrentUser\AppData\Local\Mozilla\Firefox\Profiles\*.default\cookies.sqlite -Recurse -Force -EA SilentlyContinue | Out-Null
	Remove-Item -path C:\Users\$CurrentUser\AppData\Local\Mozilla\Firefox\Profiles\*.default\webappsstore.sqlite -Recurse -Force -EA SilentlyContinue | Out-Null
	Remove-Item -path C:\Users\$CurrentUser\AppData\Local\Mozilla\Firefox\Profiles\*.default\chromeappsstore.sqlite -Recurse -Force -EA SilentlyContinue | Out-Null
	
	
	#"-------------------"
	# Clear Google Chrome 
	#"-------------------"
	
	Remove-Item -path "C:\Users\$CurrentUser\AppData\Local\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -EA SilentlyContinue | Out-Null
	Remove-Item -path "C:\Users\$CurrentUser\AppData\Local\Google\Chrome\User Data\Default\Cache2\entries\*" -Recurse -Force -EA SilentlyContinue | Out-Null
	Remove-Item -path "C:\Users\$CurrentUser\AppData\Local\Google\Chrome\User Data\Default\Cookies" -Recurse -Force -EA SilentlyContinue | Out-Null
	Remove-Item -path "C:\Users\$CurrentUser\AppData\Local\Google\Chrome\User Data\Default\Media Cache" -Recurse -Force -EA SilentlyContinue | Out-Null
	Remove-Item -path "C:\Users\$CurrentUser\AppData\Local\Google\Chrome\User Data\Default\Cookies-Journal" -Recurse -Force -EA SilentlyContinue | Out-Null
	# Comment out the following line to remove the Chrome Write Font Cache too.
	Remove-Item -path "C:\Users\$CurrentUser\AppData\Local\Google\Chrome\User Data\Default\ChromeDWriteFontCache" -Recurse -Force -EA SilentlyContinue | Out-Null
	
	
	#"-------------------"
	# Clear Internet Explorer
	#"-------------------"
	
	
	Remove-Item -path "C:\Users\$CurrentUser\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Recurse -Force -EA SilentlyContinue | Out-Null
	Remove-Item -path "C:\Users\$CurrentUser\AppData\Local\Microsoft\Windows\WER\*" -Recurse -Force -EA SilentlyContinue | Out-Null
	Remove-Item -path "C:\Users\$CurrentUser\AppData\Local\Temp\*" -Recurse -Force -EA SilentlyContinue | Out-Null
}

######################################################################################################################################################

# Customize for each script reciept
$SSAction = "BrowserCacheReset"
$CurrentDirectory = "Get-Location"
$RecieptFileName = "Completion_Reciept.txt"
$SoftwareCenterRecieptFolder = "C:\drivers\SoftwareCenterReciepts"

function Make-RecieptFile
{
	
	#######################################################################
	# Have PowerShell script create a reciept file when run through SCCM
	# Prevents user from seeing any "Failed" error messages when running payload-free actions from Software Center
	#######################################################################
	
	
	if (Test-Path "$SoftwareCenterRecieptFolder\$SSAction")
	{
		Copy-Item .\$RecieptFileName -Destination "$SoftwareCenterRecieptFolder\$SSAction"
	}
	else
	{
		New-Item -ItemType directory -Path "$SoftwareCenterRecieptFolder"
		New-Item -ItemType directory -Path "$SoftwareCenterRecieptFolder\$SSAction"
		Copy-Item .\$RecieptFileName -Destination "$SoftwareCenterRecieptFolder\$SSAction"
	}
	
	
}

function Remove-RecieptFile
{
	
	Remove-Item -Path "$SoftwareCenterRecieptFolder\$SSAction\$RecieptFileName" -Force
	
}

######################################################################################################################################################

# Run the script based on parameter input

if ($Action -eq "install")
{
	Clear-BrowserCaches
	Make-RecieptFile
	Write-Host "Installing"
	exit
}

if ($Action -eq "uninstall")
{
	Clear-BrowserCaches
	Remove-RecieptFile
	Write-Host "Uninstalling"
	exit	
}
