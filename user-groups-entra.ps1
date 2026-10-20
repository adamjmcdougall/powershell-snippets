$userId = Read-Host "Please enter the UPN of the targeted user"

# Get the list of objects the user is a member of
$memberOf = Get-MgUserMemberOf -UserId $userId -All

# Initialize an array to store the detailed group information
$detailedGroups = @()

# Loop through each member object and get additional details
foreach ($object in $memberOf) {
    $groupId = $object.Id

    try {
        # Get detailed information about the group
        $group = Get-MgGroup -GroupId $groupId -Select DisplayName, Id
        $detailedGroups += $group
    } catch {
        Write-Warning "Could not retrieve details for group with ID: $groupId"
    }
}

# Display the detailed group information
$detailedGroups | Sort-Object DisplayName | Format-Table -Property DisplayName, Id -AutoSize