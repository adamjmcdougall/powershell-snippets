$searchbase= Read-Host "enter the DN of the OU you are searching within"

# Filter below will only include "NORMAL_USER_ACCOUNT" object types.
Get-ADObject -Filter 'sAMAccountType -eq 805306368' -SearchBase $searchbase | ForEach-Object {Set-ADObject -Identity ($_.distinguishedName) -Replace @{msExchHideFromAddressLists=$true}}