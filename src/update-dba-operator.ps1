#update an existing SqlAgent Operator email list to include additional recipients

Set-psrepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module -Name SqlServer -Scope CurrentUser -SkipPublisherCheck
Import-Module SqlServer

#I source my server list from a separate file, and so can you.  An example is provided her for ease of use
#. .\servers.ps1
[string[]]$serverList = @(
    "server1",
    "server2"
)

#set the operator name to *update*
$operatorName = "DBA"
$operatorEmail = "bob@your.domain;jane@your.domain"
       
$updateOperatorSql = "exec msdb.dbo.sp_update_operator @name='$operatorName', @email_address='$operatorEmail'"        


foreach ($server in $serverList) {
    try {
        Invoke-SqlCmd -ServerInstance $server -Query $updateOperatorSql
    }
    catch {
        Write-Host "Could not update operator $operatorName on host $server"
        Write-Host $_
    }
}