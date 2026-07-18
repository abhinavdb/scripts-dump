The migration is planned using ola backup script in which below things are happening

1) use ola backup scrript to take backup in source on-prem folder
F:\backups\ ola will create server name folder\database names folder\ full or log or diff

2) Powershell
PS : we have to pass the source folder name , F:\backups\ ola will create server name folder; and pass container name in PS
now the ps will go inside every folder of databases names automatically and copy all the files in blob container.
but it will take care of only copying main backup files from source strucuture to destination folders.
Ex destination folder : container name\databases names folders seperately\dump all the files from different ola style source folders here directly.

since MI does not support different folder structure: after container name, we can have folder with DB names but after that no folder it support, thats
why our script will copy the backup files here and skip if already exists.

3) Now Azure data studio automatic migration will pick log backups automatically , no need to do anything, just monitor