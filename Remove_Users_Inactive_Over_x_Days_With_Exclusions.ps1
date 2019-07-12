
############################################################################################
# Remove users not accessed in 30 days or over
# Greg Knackstedt
# 
# 7.11.2017
#
# This script will identify and remove all users inactive for 30+ days. Excluding accounts defined below
# Verified working w/Powershell 2.0 on 7.11.2019
#
############################################################################################
#
# Set maximum last login date for user profile.
# Example: 30 = 30 days
$AccountAgeOver = "30"
#
############################################################################################
#
# User accounts to exclude
$ExcludeAccountOne = "C:\Users\username"
$ExcludeAccountTwo = "C:\Users\username"
$ExcludeAccountTwo = "C:\Users\username"
#
############################################################################################

# Get user profiles - Where - not a special account, not currently logged in, last login over $AccountAgeOver days ago, and user is not LTS_Support, MGT_Support, or vmadmin
Get-WmiObject Win32_UserProfile | Where-Object { (!$_.Special) -and ($_.Loaded -eq "$LoginState") -and ($_.ConvertToDateTime($_.LastUseTime) -lt ((Get-Date).AddDays($AccountAgeOver))) -and ($_.LocalPath -notcontains "$ExcludeAccountOne") -and ($_.LocalPath -notcontains "$ExcludeAccountTwo") -and ($_.LocalPath -notcontains "$ExcludeAccountThree")} | Remove-WmiObject

