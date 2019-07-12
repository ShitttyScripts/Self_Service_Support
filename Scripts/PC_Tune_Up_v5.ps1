<#	
	
	===========================================================================
	 Created on:   	7/9/19 11:30 AM
	 Created by:   	GKnackstedt
	 Filename:     	PC_Tune_Up_v5.ps1
	===========================================================================
	.DESCRIPTION
		Clears local users not accessed in 30 days, all user and system level temp/cache files, SoftwareDistribution Folder, all browser temp/cache files, and ccmcache files over 20 days old.
#>

######################################################################################################################################################
# Identify Current User And Set Variable
#Get logged on User
$Loggedon = Get-WmiObject -ComputerName $env:COMPUTERNAME -Class Win32_Computersystem | Select-Object UserName
#Split User and Domain
$DomainName, $CurrentUser = $Loggedon.Username.split('\', 2)
Write-Host $DomainName
Write-Host $CurrentUser
######################################################################################################################################################
# Remove users not accessed in 30 days or over
# This script will identify and remove all users inactive for 30+ days. Excluding accounts defined below
#
# Set maximum last login date for user profile.
# Example: 30 = 30 days
$AccountAgeOver = "30"
#
############################################################################################
#
# User accounts to exclude
$ExcludeAccountOne = "C:\Users\USERNAME"
$ExcludeAccountTwo = "C:\Users\USERNAME"
$ExcludeAccountTwo = "C:\Users\USERNAME"
#
############################################################################################

# Get user profiles where the following are true. It is not a special account, not currently logged in, last login over $AccountAgeOver days ago, and user is not LTS_Support, MGT_Support, or vmadmin
Get-WmiObject Win32_UserProfile | Where-Object { (!$_.Special) -and ($_.Loaded -eq "$LoginState") -and ($_.ConvertToDateTime($_.LastUseTime) -lt ((Get-Date).AddDays($AccountAgeOver))) -and ($_.LocalPath -notcontains "$ExcludeAccountOne") -and ($_.LocalPath -notcontains "$ExcludeAccountTwo") -and ($_.LocalPath -notcontains "$ExcludeAccountThree") } | Remove-WmiObject


####################  Remove all Temp Files #################### 
$TempFileLocation = "$env:windir\Temp", "$env:TEMP"

$TempFile = Get-ChildItem $TempFileLocation -Recurse
$TempFileCount = ($TempFile).count

if ($TempFileCount -eq "0")
{
}
Else
{
	$TempFile | Remove-Item -Confirm:$false -Recurse -Force -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | Out-Null
}


######################################################################################################################################################

#################### Clear SoftwareDistribution Folder #################### 

$SoftwareDistributionLocation = "$env:windir\SoftwareDistribution\Download"
$SoftwareDistribution = Get-ChildItem $SoftwareDistributionLocation -Recurse
$SoftwareDistributionCount = ($SoftwareDistribution).Count

if ($SoftwareDistributionCount -eq "0")
{
}
Else
{
	$SoftwareDistribution | Remove-Item -Confirm:$false -Recurse -Force -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | Out-Null
}
######################################################################################################################################################

#################### Clear All Browser Caches And Temp Files #################### 


#https://github.com/lemtek/Powershell/blob/master/Clear_Browser_Caches
# List the users in c:\users and export to the local profile for calling later
dir C:\Users | select Name | Export-Csv -Path C:\users\$CurrentUser\users.csv -NoTypeInformation
$list = Test-Path C:\users\$CurrentUser\users.csv

#########################

if ($list)
{
	#"-------------------"
	#Clear Mozilla Firefox Cache
	
	#"-------------------"
	
	Import-CSV -Path C:\users\$CurrentUser\users.csv -Header Name | foreach {
		Remove-Item -path C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache\* -Recurse -Force -EA SilentlyContinue | Out-Null
		Remove-Item -path C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache\*.* -Recurse -Force -EA SilentlyContinue | Out-Null
		Remove-Item -path C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache2\entries\*.* -Recurse -Force -EA SilentlyContinue | Out-Null
		Remove-Item -path C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\thumbnails\* -Recurse -Force -EA SilentlyContinue | Out-Null
		Remove-Item -path C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\cookies.sqlite -Recurse -Force -EA SilentlyContinue | Out-Null
		Remove-Item -path C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\webappsstore.sqlite -Recurse -Force -EA SilentlyContinue | Out-Null
		Remove-Item -path C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\chromeappsstore.sqlite -Recurse -Force -EA SilentlyContinue | Out-Null
	}
	
	#"-------------------"
	# Clear Google Chrome 
	#"-------------------"
	Import-CSV -Path C:\users\$CurrentUser\users.csv -Header Name | foreach {
		Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -EA SilentlyContinue | Out-Null
		Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Cache2\entries\*" -Recurse -Force -EA SilentlyContinue | Out-Null
		Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Cookies" -Recurse -Force -EA SilentlyContinue | Out-Null
		Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Media Cache" -Recurse -Force -EA SilentlyContinue | Out-Null
		Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Cookies-Journal" -Recurse -Force -EA SilentlyContinue | Out-Null
		# Comment out the following line to remove the Chrome Write Font Cache too.
		Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\ChromeDWriteFontCache" -Recurse -Force -EA SilentlyContinue | Out-Null
	}
	
	#"-------------------"
	# Clear Internet Explorer
	#"-------------------"
	
	Import-CSV -Path C:\users\$CurrentUser\users.csv | foreach {
		Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Recurse -Force -EA SilentlyContinue | Out-Null
		Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Microsoft\Windows\WER\*" -Recurse -Force -EA SilentlyContinue | Out-Null
		Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Temp\*" -Recurse -Force -EA SilentlyContinue | Out-Null
		
	}
	Import-CSV -Path C:\users\$CurrentUser\users.csv | foreach {
		#"-------------------"
		# Windows Temp Files
		#"-------------------"
		Remove-Item -path "C:\Windows\Temp\*" -Recurse -Force -EA SilentlyContinue | Out-Null
		Remove-Item -path "C:\`$recycle.bin\" -Recurse -Force -EA SilentlyContinue | Out-Null
	}
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
}
else
{
}

######################################################################################################################################################

#################### Remove CCMCACHE Files Over 20 Days Old #################### 


# Delete all Files in C:\Windows\ccmcache older than 30 day(s)
$SCCMCacheLocation = "C:\Windows\ccmcache"
$FilesOverXDays = "-30"

$CurrentDate = Get-Date
$FilesToDelete = $CurrentDate.AddDays($FilesOverXDays)
Get-ChildItem $SCCMCacheLocation -Recurse | Where-Object { $_.LastWriteTime -lt $FilesToDelete } | Remove-Item -Recurse -Force -EA SilentlyContinue | Out-Null


######################################################################################################################################################

# Set exit code
Write-Host 'Completed'