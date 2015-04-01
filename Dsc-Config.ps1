Configuration windowstest {
 
<#
 param(
 [Parameter(Mandatory=$true)]
 [System.Management.Automation.Credential()]$credential = [System.Management.Automation.Credential]

 )
#>

 
Import-DscResource -ModuleName xsmbshare,hostsfile,RecylceBin,xDisk,cFileShare,cFolderQuota,xnetworking
 ##Testing all installed windows features
 
 Node $AllNodes.Where({$_.name -eq'server1'}).nodename {
 
 
                      
  <# $ConfigurationData.try.installed.foreach({
   WindowsFeature  $_ {
   Name = $_
   Ensure = "present"
   }

   
}) #>


 ##Testing all installed windows features                     

 
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


 LocalConfigurationManager {


 CertificateID = "95E7CC6CC454894381794CDD1610455A18146992"
 ConfigurationMode = "ApplyandMonitor"





 }



## Creating PArtitions


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


          xDisk Development
        {
          
             DiskNumber = 3
             DriveLetter = 'W'
        }



          xDisk Administration
        {
          
             DiskNumber = 4
             DriveLetter = 'G'
        }






## Assigning  Perrmissions 
    
    
          xSmbShare  Libary  {

   Name = 'Libary'
   Path = 'j:\'
   Ensure = 'present'
   ReadAccess = 'SUPERMARIO\ElaineJ'
   FullAccess = 'SUPERMARIO\MichaelS'
   FolderEnumerationMode = 'AccessBased'
   DependsOn = '[xDisk]Libary'
  
   
 
            }


                xSmbShare  Client {

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

                xSmbShare  Development {

   Name = 'Development'
   Path = 'W:\'
   Ensure = 'present'
   ChangeAccess = 'SUPERMARIO\ElaineJ'
   FullAccess = 'SUPERMARIO\Administrator'
   NoAccess = 'SUPERMARIO\MarianG','SUPERMARIO\NOOB'
   ReadAccess = 'SUPERMARIO\Mario','SUPERMARIO\MichaelS'
   EncryptData = $true
   FolderEnumerationMode = 'AccessBased'
   DependsOn = '[xDisk]Development'
   
   
            }

              xSmbShare  User1s {

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

## Assigniong Perrmissions 
                     
                       }
                       
 Node $AllNodes.Where({$_.name -eq'windows8'}).nodename {


 
 xSmbShare  Clients {

   Name = "Clients"
   Path = "C:\Testwindows"
   Ensure = "present"
   NoAccess = "SUPERMARIO\MarianG"
   ReadAccess = "SUPERMARIO\MariuszS","SUPERMARIO\Mario"
   Description = "Testwindows"
 
            }

 xSmbShare  Libary {

   Name = "Libary"
   Path = "C:\Testwindows1"
   Ensure = "present"
   FullAccess = "SUPERMARIO\Administrator"
   NoAccess = "SUPERMARIO\NOOB","SUPERMARIO\MarianG"
   ReadAccess = "SUPERMARIO\MariuszS"
   Description = "Testwindowsyoyoyoyo"

   
            }


 xDNSServerAddress DNSSetup {


 InterfaceAlias = "Internal"
 Address = "192.168.233.10","8.8.8.8"
 AddressFamily = "Ipv4"


 }


 xIPAddress StaticIp {


 InterfaceAlias = "Internal"
 AddressFamily = "Ipv4"
 IPAddress = "192.168.233.170"
 SubnetMask = 255.255.255.0
 DefaultGateway = "192.168.233.50"

 }



    }

}
 

$myconfig = `

@{
 


 
 
 AllNodes = @(


    




 @{
 NodeName='*'

 
 }


 @{


 NodeName='server1'
 Ensure = 'present'
 name = 'server1'
 Certificatefile = "C:\DSC\nice.cer"

 }

  @{
 NodeName='windows8'
 Ensure = 'present'
 name = 'windows8'

 }



 )

  ##Testing all installed windows features 
try = @{ installed = $jeb }
 ##Testing all installed windows features 


}

$jeb = (Get-WindowsFeature | Where-Object installstate -eq 'installed').name

windowstest  -ConfigurationData $myconfig -OutputPath 'C:\TUTAJ\' 






Start-DscConfiguration -Path C:\TUTAJ\   -Wait -Verbose -Force

