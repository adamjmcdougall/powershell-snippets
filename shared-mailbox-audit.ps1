# Source: https://techresolve.blog/2026/03/07/script-to-see-what-shared-mailboxes-each-user-has/
# Note: This is "Option 2" from the above link

Connect-ExchangeOnline

$SharedMailboxes = Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited
$PermissionsReport = @()

Write-Host "Found $($SharedMailboxes.Count) shared mailboxes. Auditing permissions..." -ForegroundColor Green

foreach ($Mailbox in $SharedMailboxes) {
    # Get FullAccess permissions
    $FullAccessPermissions = Get-MailboxPermission -Identity $Mailbox.Identity | Where-Object { ($_.User -notlike "NT AUTHORITY\*") -and ($_.IsInherited -eq $false) }
    
    foreach ($Permission in $FullAccessPermissions) {
        $PermissionsReport += [PSCustomObject]@{
            Mailbox      = $Mailbox.DisplayName
            User         = $Permission.User
            Permission   = "FullAccess"
            UserIsGroup  = (Get-Recipient -Identity $Permission.User).RecipientType -like "*Group*"
        }
    }

    # Get SendAs permissions
    $SendAsPermissions = Get-RecipientPermission -Identity $Mailbox.Identity | Where-Object { ($_.Trustee -notlike "NT AUTHORITY\*") -and ($_.IsInherited -eq $false) }

    foreach ($Permission in $SendAsPermissions) {
        $PermissionsReport += [PSCustomObject]@{
            Mailbox      = $Mailbox.DisplayName
            User         = $Permission.Trustee
            Permission   = "SendAs"
            UserIsGroup  = (Get-Recipient -Identity $Permission.Trustee).RecipientType -like "*Group*"
        }
    }
}

Write-Host "Audit complete. Exporting to CSV."
$PermissionsReport | Export-Csv -Path ".\SharedMailboxPermissions_Audit.csv" -NoTypeInformation
