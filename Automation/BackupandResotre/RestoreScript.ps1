Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true -Register
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value $false -Register

Restore-DbaDatabase -SqlInstance aznetpocdbs02 -DatabaseName MySMSConversations -Path D:\Backup\MySMSConversations -RestoreTime (Get-Date).AddMinutes(-1)  -Continue -StandbyDirectory 'C:\BackupRestoreLog\StandbyLogfile'
Restore-DbaDatabase -SqlInstance aznetpocdbs02 -DatabaseName MysmsInvoicing -Path D:\Backup\MysmsInvoicing -RestoreTime (Get-Date).AddMinutes(-1)  -Continue -StandbyDirectory 'C:\BackupRestoreLog\StandbyLogfile' 
Restore-DbaDatabase -SqlInstance aznetpocdbs02 -DatabaseName MysmsTimeTrack -Path D:\Backup\MysmsTimeTrack -RestoreTime (Get-Date).AddMinutes(-1)  -Continue -StandbyDirectory 'C:\BackupRestoreLog\StandbyLogfile' 
Restore-DbaDatabase -SqlInstance aznetpocdbs02 -DatabaseName MYSMST -Path D:\Backup\MYSMST -RestoreTime (Get-Date).AddMinutes(-1)  -Continue -StandbyDirectory 'C:\BackupRestoreLog\StandbyLogfile' 
Restore-DbaDatabase -SqlInstance aznetpocdbs02 -DatabaseName MySMSTrans -Path D:\Backup\MySMSTrans -RestoreTime (Get-Date).AddMinutes(-1)  -Continue -StandbyDirectory 'C:\BackupRestoreLog\StandbyLogfile' 
Restore-DbaDatabase -SqlInstance aznetpocdbs02 -DatabaseName MySMS -Path D:\Backup\MySMS -RestoreTime (Get-Date).AddMinutes(-1)  -Continue -StandbyDirectory 'C:\BackupRestoreLog\StandbyLogfile'
Restore-DbaDatabase -SqlInstance aznetpocdbs02 -DatabaseName MySMSAudit -Path D:\Backup\MySMSAudit -RestoreTime (Get-Date).AddMinutes(-1)  -Continue -StandbyDirectory 'C:\BackupRestoreLog\StandbyLogfile' 



Restore-DbaDatabase -SqlInstance aznetpocdbs02 -DatabaseName MySMSAudit -Path D:\Backup\MySMSAudit
Restore-DbaDatabase -SqlInstance aznetpocdbs02 -DatabaseName MySMSAudit -Path D:\Backup\MySMSAudit
Restore-DbaDatabase -SqlInstance aznetpocdbs02 -DatabaseName MySMSAudit -Path D:\Backup\MySMSAudit