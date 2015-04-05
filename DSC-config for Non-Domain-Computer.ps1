



## Setting up WSMAN Trusted Host and Copying DSC Resouces


function Setting-Connection {

 [CmdletBinding()]
                               [OutputType([int])]
  Param
  (
  [Parameter(Mandatory=$true,
  Position=0)]
  [string]$Computername
  )




$mywsman = dir WSMan:\localhost\Client\TrustedHosts

$newserver = $Computername


## creating hash table

$hash = @{


path = "WSMan:\localhost\Client\TrustedHosts"

force = $true


}


## addind comupter name to TrustedHost for WSMAN

if ($mywsman.value) {


$hash.add("value","$($mywsman.value),$newserver")



}else {

$hash.add("value",$newserver)

}

Set-Item @hash



## Copying DSC Resources to new Machine

$psdrive = @{ 

name ="Newserver"
PSprovider = "FileSystem"
root = "\\$newserver\C$\Program Files\WindowsPowerShell\modules"

}

New-PSDrive @psdrive




$a = "C:\Program Files\WindowsPowerShell\Modules\*"
$b = "Newserver:\"

$param1 = @{

path = $a
Destination = $b
container = $true
force = $true
recurse = $true
passthru = $true

}

Copy-Item @param1  | Out-Null


}



configuration newserver {

 param (
        [Parameter(Mandatory)] 
        [pscredential]$safemodeCred, 
        
        [Parameter(Mandatory)] 
        [pscredential]$domainCred,
 
        [pscredential]$Credential
    )


 Import-DscResource -Module xActiveDirectory, xComputerManagement, xNetworking,xDhcpServer,xDisk,cSmbShare,cFolderQuota  


Node $AllNodes.nodename {


##Config of LCM

 LocalConfigurationManager {
           
            RebootNodeIfNeeded = $true
            
                            }

##  Config  DNS 

xDNSServerAddress SetDNS {
            Address = $Node.DNSAddress
            InterfaceAlias = $Node.InterfaceAlias
            AddressFamily = $Node.AddressFamily
        }


##  Config  Name 
xComputer SetName { 
          Name = $Node.MachineName 


        }

xADDomain FirstDC {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeCred
            DependsOn = '[xComputer]SetName', '[WindowsFeature]ADDSInstall'
        }


##  Installing windows Features

WindowsFeature ADDSInstall {
            Ensure = 'Present'
            Name = 'AD-Domain-Services'
            DependsOn = "[xComputer]SetName"
        }

WindowsFeature DHCP {
            Ensure = 'Present'
            Name = 'DHCP'
            IncludeAllSubFeature = $true
            DependsOn = "[xADDomain]FirstDC"
        }

WindowsFeature RSAT-ADDS-Tools {
 
                    Name = 'RSAT-ADDS-Tools'
                    Ensure = 'Present'
                    DependsOn = "[xADDomain]FirstDC"
 
                }

WindowsFeature RSAT-ADDS {
 
                    Name = 'RSAT-ADDS'
                    Ensure = 'Present'
                    DependsOn = "[xADDomain]FirstDC"
                }

WindowsFeature RSAT-AD-Tools {
 
                    Name = 'RSAT-AD-Tools'
                    Ensure = 'Present'
                    DependsOn = "[xADDomain]FirstDC"
                }

WindowsFeature RSAT-AD-AdminCenter {
 
                    Name = 'RSAT-AD-AdminCenter'
                    Ensure = 'Present'
                    DependsOn = "[xADDomain]FirstDC"
                }

WindowsFeature RSAT-DHCP {
 
                    Name = 'RSAT-DHCP'
                    Ensure = 'Present'
                    DependsOn = "[xADDomain]FirstDC","[WindowsFeature]DHCP"
                }

WindowsFeature FileAndStorage-Services  {
 
                    Name = 'FileAndStorage-Services'
                    Ensure = 'Present'
                    IncludeAllSubFeature = $true
                    DependsOn = "[xADDomain]FirstDC","[WindowsFeature]DHCP"
                }

WindowsFeature FS-Resource-Manager  {
 
                    Name = 'FS-Resource-Manager'
                    Ensure = 'Present'
                    IncludeAllSubFeature = $true
                    DependsOn = "[WindowsFeature]FileAndStorage-Services"
                }

WindowsFeature  RSAT-File-Services {
 
                    Name = 'RSAT-File-Services'
                    Ensure = 'Present'
                    IncludeAllSubFeature = $true
                    DependsOn = "[WindowsFeature]FS-Resource-Manager"
                }


## Seting up DHCP 
xDhcpServerScope settingscope {

        Name = 'DC01'
        LeaseDuration = '00:08:00'
        State = 'Active'
        AddressFamily = 'IPv4'
        IPStartRange = '192.168.233.1'  
        IPEndRange = '192.168.233.254'
        SubnetMask = '255.255.255.0'
        Ensure = 'Present'
        DependsOn = "[WindowsFeature]DHCP"
}
    
xDhcpServerOption     settingsforDHCP {


        Ensure = 'Present' 
        ScopeID = '192.168.233.0'
        DnsDomain = 'mario.com' 
        DnsServerIPAddress = '192.168.233.27','8.8.8.8'
        AddressFamily = 'IPv4'
        DependsOn = "[WindowsFeature]DHCP" 
}

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
   ReadAccess = 'everyone'
   FullAccess = 'MARIO\Administrator' 
   FolderEnumerationMode = 'AccessBased'
   DependsOn = '[xDisk]Libary'
  
   
 
            }

          cSmbShare  Client {

   Name = 'Client'
   Path = 'K:\'
   Ensure = 'present'
   FullAccess = 'MARIO\Administrator' 
   ReadAccess = 'everyone'
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
   FullAccess = 'MARIO\Administrator'
   ReadAccess = 'everyone'
   EncryptData = $false
   DependsOn = '[xDisk]PullServer'
   
   
            }

          cSmbShare  Users {

   Name = 'Users'
   Path = 'G:\'
   Ensure = 'present'
   FullAccess = 'MARIO\Administrator'
   ReadAccess = 'everyone'
   Description = 'Administration Drive for Users'
   FolderEnumerationMode = 'Unrestricted'
   ConcurrentUserLimit = 10
   DependsOn = '[xDisk]Administration'
   
   
            }

 ## 6. Assigning Quotas


        cFolderQuota London {

        Path = 'K:\'
        Ensure = 'present'
        Template = 'London'
        Subfolders = $false
        DependsOn = '[cQuotaTemplate]NewYork'
                 }                     
        cFolderQuota 'New York' {

        Path = 'G:\'
        Ensure = 'present'
        Template = 'New York'
        Subfolders = $false
        DependsOn = '[cQuotaTemplate]NewYork'

                             }
        cFolderQuota 'Single Folder' {

        Path = 'J:\' 
        Ensure = 'present'
        Template = 'Generic'
        Subfolders = $false
        DependsOn = '[cQuotaTemplate]Generic'

                             }
        cFolderQuota 'Warsaw' {

        Path = 'W:\'
        Ensure = 'present'
        Template = 'Monitor 500 MB Share'
        Subfolders = $false
        DependsOn = '[cQuotaTemplate]Generic'

                             }



## Creating Quotas Templates

        cQuotaTemplate NewYork {

        Name = 'New York'
        Size = 11mb
        Description = 'London Template'
        MailTo = 'Supermario@supermario.com;Administrator@supermario.com;Supermario@supermario.com'
        Body = 'You have Reached your Limit of Space Please Please '
        Subject = 'We Love Arsenal :)'
        Percentage = 12
        Ensure = 'present'
        SoftLimit =$false
        DependsOn = "[WindowsFeature]FS-Resource-Manager"
        

        }
        cQuotaTemplate london {

        Name = 'London'
        Size = 350mb
        Description = 'NewYork Template'
        MailTo = 'Supermario@supermario.com'
        Body = 'WE Love Powershell Dont exeedec your SPACE !!!'
        Subject = 'We Lov Powershell DSC'
        Percentage = 11
        Ensure = 'present'
        SoftLimit =$false
        DependsOn = "[WindowsFeature]FS-Resource-Manager"
        

        }
        cQuotaTemplate Generic {

        Name = 'Generic'
        Size = 10GB
        Description = 'User Template'
        MailTo = 'Owner'
        Percentage = 78
        Ensure = 'present'
        SoftLimit =$true
        DependsOn = "[WindowsFeature]FS-Resource-Manager"
        

        }
   
    
    }




                                                    }

    
$DevConfig = @{
            AllNodes = 
 @(

 @{
 
    NodeName = '*'
    PSDscAllowPlainTextPassword = $True
 
    },



@{
            NodeName = '192.168.233.27'
            MachineName = 'DC01'
            DomainName = 'mario.com'
            IPAddress = '192.168.233.20'
            InterfaceAlias = 'Ethernet'
            DefaultGateway = '192.168.233.50'
            SubnetMask = '24'
            AddressFamily = 'IPv4'
            DNSAddress = '127.0.0.1','8.8.8.8'
}
           
);
               } 




newserver -ConfigurationData $DevConfig   -OutputPath "C:\New Server DSC" -Credential $cred -domainCred $cred -safemodeCred $cred 





$cred = Get-Credential




Set-DscLocalConfigurationManager -Path "C:\New Server DSC" -Credential $cred -Verbose 

Start-DscConfiguration "C:\New Server DSC"  -Credential $cred -Wait  -Verbose -Force

Test-DscConfiguration -CimSession $session  -Verbose


$session = New-CimSession -Credential $cred -ComputerName "dc01" 