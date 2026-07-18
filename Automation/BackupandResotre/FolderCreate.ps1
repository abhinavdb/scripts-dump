# Define the main folder and subfolders
$mainFolder = "D:\Backup"
$subFolders = @("MySMSConversations", "MysmsInvoicing", "MYSMST", "MysmsTimeTrack", "MySMSTrans","MySMS","MySMSAudit")

# Check if the main folder already exists
if (Test-Path $mainFolder) {
    Write-Output "The folder $mainFolder already exists. Exiting..."
    exit
}

# Create the main folder
New-Item -Path $mainFolder -ItemType Directory

# Create the subfolders
$subFolders | ForEach-Object {
    $subFolderPath = Join-Path -Path $mainFolder -ChildPath $_
    New-Item -Path $subFolderPath -ItemType Directory
}
