<#	
	.notes
	===========================================================================
	 created with: 	sapien technologies, inc., powershell studio 2019 v5.6.160
	 created on:   	7/9/19 11:30 am
	 created by:   	gknackstedt
	 filename:     	windows_10_pre_install_clean_up_v14.ps1
	===========================================================================
	.description
		clears local users not accessed in x days, all user and system level temp/cache files, softwaredistribution folder, all browser temp/cache files. also, ccmcache files over x days old.
#>
######################################################################################################################################################
########################## set variables for script here ############################################################################################
######################### Parameters for -Action switch install/uninstall
param (
	[Parameter(Mandatory = $True)]
	[string]$Action
)

########################## identify current user
# get logged on user
$loggedon = microsoft.powershell.management\get-wmiobject -computername $env:computername -class win32_computersystem | microsoft.powershell.utility\select-object username
# split user and domain
$domainname, $currentuser = $loggedon.username.split('\', 2)

########################## list the users in c:\users and export to the local profile for calling later
# write list of user directories out to a csv to the user running the script's home folder root
microsoft.powershell.management\get-childitem c:\users | microsoft.powershell.utility\select-object name | microsoft.powershell.utility\export-csv -path c:\users\$currentuser\users.csv -notypeinformation
$userlist = microsoft.powershell.management\test-path c:\users\$currentuser\users.csv

########################## remove old accounts
# set maximum last login date for user profile.
# example: 30 = 30 days
$accountageover = "30"
$currentdate = microsoft.powershell.utility\get-date
$usersoverxdays = $currentdate.adddays("-$accountageover")
# user accounts to exclude
$excludeaccountone = "c:\users\USERNAME"
$excludeaccounttwo = "c:\users\USERNAME"
$excludeaccountthree = "c:\users\USERNAME"

########################## clear temp files
# temp folder directories to clear
$tempfilelocations = "$env:windir\temp", "$env:temp"

########################## ccmcache files
# delete all files in c:\windows\ccmcache older than x day(s)
$sccmcachelocation = "c:\windows\ccmcache"
# remove files over x days old
$ccmcachefilesoverxdays = "20"
# today's date
#$currentdate = get-date - already set above
$ccmcachetotrash = $currentdate.adddays("-$ccmcachefilesoverxdays")

######################### receipt file
# Customize for each script receipt
$SSAction = "Win10CleanUp"
$receiptFileName = "Completion_receipt.txt"
$SoftwareCenterreceiptFolder = "C:\drivers\SoftwareCenterreceipts"

######################################################################################################################################################
###################### Define Functions ##############################################################################################################
######################################################################################################################################################
################ write-host variables input from above
function whatareyoudoing
{
	microsoft.powershell.utility\write-host "this script is running under the following user's credentials: 
	"$domainname"\"$currentuser""
	microsoft.powershell.utility\write-host "removing windows user accounts that have been inactive since $usersoverxdays"
	microsoft.powershell.utility\write-host "excluding accounts:
	$excludeaccountone
	$excludeaccounttwo 
	$excludeaccountthree"
	microsoft.powershell.utility\write-host "clearing the following directories: $tempfilelocations"
	microsoft.powershell.utility\write-host "removing ccmcache files created before "$ccmcachetotrash""
}

######################################################################################################################################################
# remove users not accessed in 30 days or over
function removeoldusers
{
	# get user profiles where the following are true. it is not a special account, not currently logged in, last login over $accountageover days ago, and user is not lts_support, mgt_support, or vmadmin
	microsoft.powershell.management\get-wmiobject win32_userprofile | microsoft.powershell.core\where-object { (!$_.special) -and ($_.loaded -eq "$loginstate") -and ($_.converttodatetime($_.lastusetime) -lt ((microsoft.powershell.utility\get-date).adddays($accountageover))) -and ($_.localpath -notcontains "$excludeaccountone") -and ($_.localpath -notcontains "$excludeaccounttwo") -and ($_.localpath -notcontains "$excludeaccountthree") } | microsoft.powershell.management\remove-wmiobject
}

####################  remove all temp files #################### 
function removealltempfiles
{
	
	
	$tempfile = microsoft.powershell.management\get-childitem $tempfilelocations -recurse
	$tempfilecount = ($tempfile).count
	
	if ($tempfilecount -eq "0")
	{
	}
	else
	{
		$tempfile | microsoft.powershell.management\remove-item -confirm:$false -recurse -force -warningaction silentlycontinue -erroraction silentlycontinue | microsoft.powershell.core\out-null
	}
}

#################### clear all browser caches and temp files #################### 
#https://github.com/lemtek/powershell/blob/master/clear_browser_caches
function clearallbrowsertemp
{
	
	if ($userlist)
	{
		#"-------------------"
		#clear mozilla firefox cache
		
		#"-------------------"
		
		microsoft.powershell.utility\import-csv -path c:\users\$currentuser\users.csv -header name | microsoft.powershell.core\foreach-object {
			microsoft.powershell.management\remove-item -path c:\users\$($_.name)\appdata\local\mozilla\firefox\profiles\*.default\cache\* -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
			microsoft.powershell.management\remove-item -path c:\users\$($_.name)\appdata\local\mozilla\firefox\profiles\*.default\cache\*.* -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
			microsoft.powershell.management\remove-item -path c:\users\$($_.name)\appdata\local\mozilla\firefox\profiles\*.default\cache2\entries\*.* -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
			microsoft.powershell.management\remove-item -path c:\users\$($_.name)\appdata\local\mozilla\firefox\profiles\*.default\thumbnails\* -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
			microsoft.powershell.management\remove-item -path c:\users\$($_.name)\appdata\local\mozilla\firefox\profiles\*.default\cookies.sqlite -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
			microsoft.powershell.management\remove-item -path c:\users\$($_.name)\appdata\local\mozilla\firefox\profiles\*.default\webappsstore.sqlite -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
			microsoft.powershell.management\remove-item -path c:\users\$($_.name)\appdata\local\mozilla\firefox\profiles\*.default\chromeappsstore.sqlite -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
		}
		
		#"-------------------"
		# clear google chrome 
		#"-------------------"
		microsoft.powershell.utility\import-csv -path c:\users\$currentuser\users.csv -header name | microsoft.powershell.core\foreach-object {
			microsoft.powershell.management\remove-item -path "c:\users\$($_.name)\appdata\local\google\chrome\user data\default\cache\*" -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
			microsoft.powershell.management\remove-item -path "c:\users\$($_.name)\appdata\local\google\chrome\user data\default\cache2\entries\*" -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
			microsoft.powershell.management\remove-item -path "c:\users\$($_.name)\appdata\local\google\chrome\user data\default\cookies" -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
			microsoft.powershell.management\remove-item -path "c:\users\$($_.name)\appdata\local\google\chrome\user data\default\media cache" -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
			microsoft.powershell.management\remove-item -path "c:\users\$($_.name)\appdata\local\google\chrome\user data\default\cookies-journal" -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
			# comment out the following line to remove the chrome write font cache too.
			microsoft.powershell.management\remove-item -path "c:\users\$($_.name)\appdata\local\google\chrome\user data\default\chromedwritefontcache" -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
		}
		
		#"-------------------"
		# clear internet explorer
		#"-------------------"
		
		microsoft.powershell.utility\import-csv -path c:\users\$currentuser\users.csv | microsoft.powershell.core\foreach-object {
			microsoft.powershell.management\remove-item -path "c:\users\$($_.name)\appdata\local\microsoft\windows\temporary internet files\*" -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
			microsoft.powershell.management\remove-item -path "c:\users\$($_.name)\appdata\local\microsoft\windows\wer\*" -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
			microsoft.powershell.management\remove-item -path "c:\users\$($_.name)\appdata\local\temp\*" -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
			
		}
		microsoft.powershell.utility\import-csv -path c:\users\$currentuser\users.csv | microsoft.powershell.core\foreach-object {
			#"-------------------"
			# windows temp files
			#"-------------------"
			microsoft.powershell.management\remove-item -path "c:\windows\temp\*" -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
			microsoft.powershell.management\remove-item -path "c:\`$recycle.bin\" -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
		}
	}
	else
	{
		
	}
}

#################### remove current user temp files ###################
function removecurrentusertempfiles
{
	
	#clear mozilla firefox cache
	
	microsoft.powershell.management\remove-item -path c:\users\$currentuser\appdata\local\mozilla\firefox\profiles\*.default\cache\* -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
	microsoft.powershell.management\remove-item -path c:\users\$currentuser\appdata\local\mozilla\firefox\profiles\*.default\cache\*.* -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
	microsoft.powershell.management\remove-item -path c:\users\$currentuser\appdata\local\mozilla\firefox\profiles\*.default\cache2\entries\*.* -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
	microsoft.powershell.management\remove-item -path c:\users\$currentuser\appdata\local\mozilla\firefox\profiles\*.default\thumbnails\* -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
	microsoft.powershell.management\remove-item -path c:\users\$currentuser\appdata\local\mozilla\firefox\profiles\*.default\cookies.sqlite -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
	microsoft.powershell.management\remove-item -path c:\users\$currentuser\appdata\local\mozilla\firefox\profiles\*.default\webappsstore.sqlite -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
	microsoft.powershell.management\remove-item -path c:\users\$currentuser\appdata\local\mozilla\firefox\profiles\*.default\chromeappsstore.sqlite -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
	
	
	#"-------------------"
	# clear google chrome 
	#"-------------------"
	
	microsoft.powershell.management\remove-item -path "c:\users\$currentuser\appdata\local\google\chrome\user data\default\cache\*" -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
	microsoft.powershell.management\remove-item -path "c:\users\$currentuser\appdata\local\google\chrome\user data\default\cache2\entries\*" -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
	microsoft.powershell.management\remove-item -path "c:\users\$currentuser\appdata\local\google\chrome\user data\default\cookies" -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
	microsoft.powershell.management\remove-item -path "c:\users\$currentuser\appdata\local\google\chrome\user data\default\media cache" -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
	microsoft.powershell.management\remove-item -path "c:\users\$currentuser\appdata\local\google\chrome\user data\default\cookies-journal" -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
	# comment out the following line to remove the chrome write font cache too.
	microsoft.powershell.management\remove-item -path "c:\users\$currentuser\appdata\local\google\chrome\user data\default\chromedwritefontcache" -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
	
	
	#"-------------------"
	# clear internet explorer
	#"-------------------"
	
	
	microsoft.powershell.management\remove-item -path "c:\users\$currentuser\appdata\local\microsoft\windows\temporary internet files\*" -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
	microsoft.powershell.management\remove-item -path "c:\users\$currentuser\appdata\local\microsoft\windows\wer\*" -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
	microsoft.powershell.management\remove-item -path "c:\users\$currentuser\appdata\local\temp\*" -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
	
}

#################### clear softwaredistribution folder #################### 
function clearsoftwaredistributionfolder
{
	$softwaredistributionlocation = "$env:windir\softwaredistribution\download"
	$softwaredistributioncontents = microsoft.powershell.management\get-childitem $softwaredistributionlocation -recurse
	$softwaredistributioncount = ($softwaredistributioncontents).count
	
	if ($softwaredistributioncount -eq "0")
	{
	}
	else
	{
		$softwaredistributioncontents | microsoft.powershell.management\remove-item -confirm:$false -recurse -force -warningaction silentlycontinue -erroraction silentlycontinue | microsoft.powershell.core\out-null
	}
}

####################  remove all temp files #################### 
function removealltempfiles
{
	
	
	$tempfile = microsoft.powershell.management\get-childitem $tempfilelocations -recurse
	$tempfilecount = ($tempfile).count
	
	if ($tempfilecount -eq "0")
	{
	}
	else
	{
		$tempfile | microsoft.powershell.management\remove-item -confirm:$false -recurse -force -warningaction silentlycontinue -erroraction silentlycontinue | microsoft.powershell.core\out-null
	}
}

#################### remove ccmcache files over x days old #################### 
function clearccmcacheover
{
	
	microsoft.powershell.management\get-childitem $sccmcachelocation -recurse | microsoft.powershell.core\where-object { $_.lastwritetime -lt $ccmcachetotrash } | microsoft.powershell.management\remove-item -recurse -force -erroraction silentlycontinue | microsoft.powershell.core\out-null
}


########################################## receipt File copy/remove ############################################################################################################
function Make-receiptFile
{
	
	#######################################################################
	# Have PowerShell script create a receipt file when run through SCCM
	# Prevents user from seeing any "Failed" error messages when running payload-free actions from Software Center
	#######################################################################
	
	
	if (Test-Path "$SoftwareCenterreceiptFolder\$SSAction")
	{
		Copy-Item .\$receiptFileName -Destination "$SoftwareCenterreceiptFolder\$SSAction"
	}
	else
	{
		New-Item -ItemType directory -Path "$SoftwareCenterreceiptFolder"
		New-Item -ItemType directory -Path "$SoftwareCenterreceiptFolder\$SSAction"
		Copy-Item .\$receiptFileName -Destination "$SoftwareCenterreceiptFolder\$SSAction"
	}
	
	
}

function Remove-receiptFile
{
	
	Remove-Item -Path "$SoftwareCenterreceiptFolder\$SSAction\$receiptFileName" -Force
	
}

######################################################################################################################################################
######################################################################################################################################################
####################### run the script ###############################################################################################################
######################################################################################################################################################
# Run the script based on parameter input

if ($Action -eq "install")
{
	Write-Host "Installing"
	whatareyoudoing
	removeoldusers
	clearallbrowsertemp
	removecurrentusertempfiles
	clearsoftwaredistributionfolder
	removealltempfiles
	clearccmcacheover
	Make-receiptFile
	
	microsoft.powershell.utility\write-host 'completed'
	
}

if ($Action -eq "uninstall")
{
	Write-Host "Uninstalling"
	whatareyoudoing
	removeoldusers
	clearallbrowsertemp
	removecurrentusertempfiles
	clearsoftwaredistributionfolder
	removealltempfiles
	clearccmcacheover
	Remove-receiptFile
	microsoft.powershell.utility\write-host 'completed'
	
}




microsoft.powershell.utility\write-host 'completed'