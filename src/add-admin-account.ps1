#add a windows group to every server in a list, granting that group SaysAdmin privs

Set-psrepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module -Name SqlServer -Scope CurrentUser -SkipPublisherCheck
Import-Module SqlServer

#I source my server list from a separate file, and so can you.  An example is provided her for ease of use
#. .\servers.ps1
[string[]]$serverList = @(
    "server1",
    "server2"
)

#account name
$account = "DOMAIN\DBA.Group.Name"
#my account was a WindowsGroup.  Yours may vary
$accountType = "WindowsGroup"
$defaultDatabase = "master"

$loops = 0
foreach ($server in $serverList) {
    $loops++
    Write-Progress -Activity "Configuring DBA group for servers" `
        -Status "Adding Windows Group $account as login for server $server" `
        -PercentComplete $($loops/($serverList).Count*100) `

    try {
        #create the login
        $login = Add-SqlLogin -Enable -GrantConnectSql -LoginName $account -LoginType $accountType `
            -DefaultDatabase $defaultDatabase -ServerInstance $server

        #add the login to the role
        $roleString = "exec sp_addsrvrolemember '$account', 'sysadmin'"
        #$roleString
        Invoke-sqlcmd -ServerInstance $server -Query $roleString
    }
    catch {
        Write-host "An error occurred for server $server"
        Write-host $_
    }
}

