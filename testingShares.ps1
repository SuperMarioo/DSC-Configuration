


 Set-TargetResource @has -Debug




Test-TargetResource @has -Debug




$has = @{



    Name = 'Users'
   Path = 'G:\'
   Ensure = 'present'
   ChangeAccess = 'everyone'
   FullAccess = 'SUPERMARIO\MariuszS'
   ReadAccess = 'SUPERMARIO\MarianG','SUPERMARIO\ElaineJ'
   Description = 'Administration Drive for Users'
   FolderEnumerationMode = 'AccessBased'
   ConcurrentUserLimit = 12
   EncryptData = $false
  


}

$has = @{
    Name = 'Libary'
   Path = 'j:\'
   Ensure = 'present'
   ReadAccess = 'SUPERMARIO\ElaineJ'
   FullAccess = 'SUPERMARIO\MichaelS',"SUPERMARIO\Mario"
 
   }