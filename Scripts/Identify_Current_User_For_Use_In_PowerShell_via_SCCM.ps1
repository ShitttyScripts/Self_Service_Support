
############################################################################################
# Remove users not accessed in 30 days or over
# Created by: Greg Knackstedt
# Date: 7.12.2017
############################################################################################

#Identify currently logged in user
$ActiveUser = Get-WmiObject -ComputerName $env:COMPUTERNAME -Class Win32_Computersystem | Select-Object UserName

#Seperate username into $Domain and $CurrentUsername
$DomainName,$CurrentUsername = $ActiveUser.Username.split('\',2)

#Display output to verify correct user detected
Write-Host $DomainName
Write-Host $CurrentUsername
