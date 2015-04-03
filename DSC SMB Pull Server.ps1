Configuration SmbPullServer {
 


 
Import-DscResource -ModuleName csmbshare,hostsfile,RecylceBin,xDisk,cFileShare,cFolderQuota,xnetworking


 
 Node $AllNodes.Where({$_.name -eq'server1'}).nodename {

 <#
 user Localadmin {


 UserName = "LocalAdmin"
 Description =  "Chicago Adminitrator"
 Disabled = $false
 Ensure = "present"
 Password = $credential


 }


 group Admin {
 GroupName = "Administrators"
 DependsOn = "[user]Localadmin"
 MembersToInclude = "Localadmin"



 }
 #>


## 1.Creating Partitions


          xDisk Libary
        {
         
             DiskNumber = 1
             DriveLetter = 'J'
        }

          xDisk Client
        {
          
             DiskNumber = 2
             DriveLetter = 'K'
        }

          xDisk PullServer
        {
          
             DiskNumber = 3
             DriveLetter = 'W'
        }

          xDisk Administration
        {
          
             DiskNumber = 4
             DriveLetter = 'G'
        }


## 2.Assigning  Perrmissions 
    
  
          cSmbShare  Libary  {

   Name = 'Libary'
   Path = 'j:\'
   Ensure = 'present'
   ReadAccess = 'SUPERMARIO\ElaineJ'
   FullAccess = 'SUPERMARIO\MichaelS'
   FolderEnumerationMode = 'AccessBased'
   DependsOn = '[xDisk]Libary'
  
   
 
            }

          cSmbShare  Client {

   Name = 'Client'
   Path = 'K:\'
   Ensure = 'present'
   ChangeAccess = 'SUPERMARIO\ElaineJ'
 
   ReadAccess = 'SUPERMARIO\Mario','SUPERMARIO\MichaelS'
   Description = 'Client Drive for Users'
   FolderEnumerationMode = 'AccessBased'
   ConcurrentUserLimit = 10
   DependsOn = '[xDisk]Client'
   
   
   
            }

          cSmbShare  PullServer {

   Name = 'PullServer'
   Path = 'W:\'
   Ensure = 'present'
   Description = "PullServer"
   FullAccess = 'SUPERMARIO\Administrator','SUPERMARIO\Mario'
   ReadAccess = 'everyone'
   EncryptData = $false
   DependsOn = '[xDisk]PullServer'
   
   
            }

          cSmbShare  Users {

   Name = 'Users'
   Path = 'G:\'
   Ensure = 'present'
   ChangeAccess = 'SUPERMARIO\ElaineJ'
   FullAccess = 'SUPERMARIO\MariuszS','SUPERMARIO\Administrator'
   ReadAccess = 'SUPERMARIO\Mario','SUPERMARIO\MichaelS'
   Description = 'Administration Drive for Users'
   FolderEnumerationMode = 'Unrestricted'
   ConcurrentUserLimit = 10
   DependsOn = '[xDisk]Administration'
   
   
            }

## 3. Add DSC Servcie Feature


          WindowsFeature DSCServcie {

           Name = 'DSC-Service'
           Ensure = 'Present'

           }

## 4. New Test Share


          cSmbShare LCM_DSC {


          Name = "DSC-LCM-CONFIG"
          Path = "C:\DSC-LCMCONFIG"
          Ensure = 'present'
          ReadAccess = 'everyone'


             }

## 5. New Test Share1


          cSmbShare DSC_CONFIG {


          Name = "DSC-CONFIG"
          Path = "C:\DSC-CONFIG"
          Ensure = 'present'
          ReadAccess = 'everyone'


             }

                       }
                       
 Node $AllNodes.Where({$_.name -eq'windows8'}).nodename {


 
 cSmbShare  Clients {

   Name = "NEY YORK CITY LAL"
   Path = "C:\Testwindows"
   Ensure = "present"
   NoAccess = "SUPERMARIO\MarianG"
   ReadAccess = "SUPERMARIO\MariuszS","SUPERMARIO\Mario"
   Description = "Testwindows"
 
            }

 cSmbShare  Libary {

   Name = "LALALA"
   Path = "C:\Testwindows1"
   Ensure = "present"
   FullAccess = "SUPERMARIO\Administrator"
   NoAccess = "SUPERMARIO\NOOB","SUPERMARIO\MarianG"
   ReadAccess = "SUPERMARIO\MariuszS"
   Description = "LALALALLA"

   
            }


 xDNSServerAddress DNSSetup {


 InterfaceAlias = "Internal"
 Address = "192.168.233.10","8.8.8.1"
 AddressFamily = "Ipv4"


 }



    }

}

## Zip Function
function Zip-Directory {
    Param(
      [Parameter(Mandatory=$True)][string]$DestinationFileName,
      [Parameter(Mandatory=$True)][string]$SourceDirectory,
      [ValidateSet("Optimal", "Fastest", "NoCompression")]
      [Parameter(Mandatory=$False)][string]$CompressionLevel = "Optimal",
      [Parameter(Mandatory=$False)][switch]$IncludeParentDir
    )
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $CompressionLevel    = [System.IO.Compression.CompressionLevel]::$CompressionLevel  
    [System.IO.Compression.ZipFile]::CreateFromDirectory($SourceDirectory, $DestinationFileName, $CompressionLevel, $IncludeParentDir)
}


## Copying DSC Resources and Creating Checksum

Get-DscResource | where path -Match "^c:\\program files\\WindowsPowershell\\Modules" | 
select -ExpandProperty module -Unique | foreach `
{

$out = "{0}_{1}.zip" -f $_.Name , $_.version

$zip = Join-Path  "W:\" -ChildPath $out

Zip-Directory -DestinationFileName $zip -SourceDirectory $_.modulebase 

Start-Sleep -Seconds 2 

if($zip) {



New-DSCCheckSum -ConfigurationPath $zip -ErrorAction SilentlyContinue


}

}
 





SmbPullServer  -ConfigurationData $myconfig -OutputPath "C:\DSC-CONFIG"






Start-DscConfiguration -Path "C:\DSC-CONFIG"   -Wait -Verbose -Force

Configuration SmbPullServerLCM {
 

 

 
 Node $AllNodes.Where({$_.name -eq'server1'}).nodename {
 
 


 LocalConfigurationManager {


     AllowModuleOverwrite = $true
     ConfigurationID = $node.guid
     ConfigurationMode = "ApplyandMonitor"
     RefreshMode = "Pull"
     DownloadManagerName = "DscFileDownloadManager"
     DownloadManagerCustomData =  @{
     SourcePath  = "\\server1\PullServer"}



 }



                       }
                       
 Node $AllNodes.Where({$_.name -eq'windows8'}).nodename {


  LocalConfigurationManager {


     AllowModuleOverwrite = $true
     ConfigurationID = $node.guid
     ConfigurationMode = "ApplyandMonitor"
     RefreshMode = "Pull"
     DownloadManagerName = "DscFileDownloadManager"
     DownloadManagerCustomData =  @{
     SourcePath  = "\\server1\PullServer"}



 }




    }

}



SmbPullServerLCM -ConfigurationData $myconfig -OutputPath "C:\DSC-LCMCONFIG"

Set-DscLocalConfigurationManager -Path "C:\DSC-LCMCONFIG" -Verbose


$myconfig = `

@{

 AllNodes = @(

 @{
 NodeName='*'

 
 }


 @{


 NodeName='server1'
 Ensure = 'present'
 Guid = [guid]::NewGuid().guid
 name = 'server1'
 

 }

  @{
 NodeName='windows8'
 Ensure = 'present'
 name = 'windows8'
 Guid = [guid]::NewGuid().guid
 }



 )



}