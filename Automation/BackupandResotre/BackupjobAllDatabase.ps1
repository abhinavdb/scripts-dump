# List of databases
$databases = @("MySMSConversations",) # Add database names here

foreach ($databaseName in $databases) {
    $sourceDir = "\\aznetpocdbs01\SQLBackup\"
    $destDir = "D:\Backup\$databaseName"
    $timeLimit = (Get-Date).AddMinutes(-60)

    Get-ChildItem -Path $sourceDir -Recurse | Where-Object {
        $_.LastWriteTime -gt $timeLimit
    } | ForEach-Object {
        $destPath = $destDir + $_.FullName.Substring($sourceDir.length)
        $destDirPath = [System.IO.Path]::GetDirectoryName($destPath)

        # Check if the file already exists in the destination
        if (Test-Path $destPath) {
            $destFile = Get-Item $destPath
            # Check if the file in the source and destination have the same last modification time and size
            if ($destFile.LastWriteTime -eq $_.LastWriteTime -and $destFile.Length -eq $_.Length) {
                Write-Output "File '$_' for database '$databaseName' already exists in destination and hasn't changed. Skipping copy."
                return
            }
        }

        # Ensure the destination directory exists
        if (-not (Test-Path $destDirPath)) {
            New-Item -ItemType Directory -Force -Path $destDirPath
        }

        # Copy the file to the destination
        Copy-Item -Path $_.FullName -Destination $destPath -Force
    }
}
