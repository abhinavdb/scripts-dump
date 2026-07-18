# List of databases
$databases = @("MySMSconversations","MysmsInvoicing","MysmsTimeTrack","MYSMST","MySMSTrans","MySMS","MySMSAudit") # Add database names here

$fileExtension = "*.trn"
$timeLimit = (Get-Date).AddHours(-1)

foreach ($databaseName in $databases) {
    $folderPath = "D:\Backup\$databaseName"

    # Fetch all .trn files older than 1 hour for the current database
    $filesToDelete = Get-ChildItem -Path $folderPath -Filter $fileExtension | Where-Object {
        $_.LastWriteTime -lt $timeLimit
    }

    # Check if there are any files to delete for the current database
    if ($filesToDelete.Count -eq 0) {
        Write-Output "No files to delete for database '$databaseName'. Continuing to the next database."
        continue
    }

    # Delete the files for the current database
    $filesToDelete | ForEach-Object {
        Remove-Item -Path $_.FullName -Force
        Write-Output ("Deleted: " + $_.FullName + " for database '$databaseName'")
    }
}
