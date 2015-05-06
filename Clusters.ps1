
function Setting-Connection {

 [CmdletBinding()]
                               [OutputType([int])]
  Param
  (
  [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,
  Position=0)]
  [string[]]$Computername,
  [PSCredential]$Credential
  )




$mywsman = dir WSMan:\localhost\Client\TrustedHosts

$newserver = $Computername


## creating hash table

foreach ($newcomputer in $newserver  ) {

$hash = @{


path = "WSMan:\localhost\Client\TrustedHosts"

force = $true


}


## addind comupter name to TrustedHost for WSMAN

if ($mywsman.value) {


$hash.add("value","$($mywsman.value),$newcomputer")



}else {

$hash.add("value",$newcomputer)

}

Set-Item @hash



## Copying DSC Resources to new Machine

$psdrive = @{ 

name ="Newserver"
PSprovider = "FileSystem"
root = "\\$newcomputer\C$\Program Files\WindowsPowerShell\modules"

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

Get-PSDrive Newserver | Remove-PSDrive | Out-Null  
}

}

Setting-Connection  -Computername DC03 -Credential $(Get-Credential)


configuration newserver {

 param (

        [Parameter(Mandatory)] 
        [pscredential]$domainCred

    )


Import-DscResource -Module xActiveDirectory, xComputerManagement, xNetworking,xFailOverCluster 

Node $AllNodes.Where({$_.MachineName -eq'S1'}).nodename {

  

## 2.Config of LCM

 LocalConfigurationManager {
           
            RebootNodeIfNeeded = $true
            ConfigurationMode = "ApplyAndAutoCorrect"
            
                            }

## 3.Config  DNS 

xDNSServerAddress SetDNS {
            Address = $Node.DNSAddress
            InterfaceAlias = $Node.InterfaceAlias
            AddressFamily = $Node.AddressFamily
            DependsOn = "[xComputer]SetName"
        }

##  Testing Ip Address 


xIPAddress  newIp {

InterfaceAlias = $Node.InterfaceAlias
IPAddress = $node.IPAddress
AddressFamily = $Node.AddressFamily
SubnetMask = 24
DefaultGateway = $node.DefaultGateway
DependsOn = "[xComputer]SetName"


}


## 4.Config  Name 
xComputer SetName { 
          Name = $Node.MachineName
          DomainName = "marioo.com"
          Credential = $domainCred 

        }
## 5. Setting up Domain Controller


## 6.Installing WindowsFeature



WindowsFeature FailoverFeature 
        { 
            Ensure = "Present" 
            Name      = "Failover-clustering" 
        }
        
        
WindowsFeature RSATClusteringPowerShell 
        { 
            Ensure = "Present" 
            Name   = "RSAT-Clustering-PowerShell"    
 
            DependsOn = "[WindowsFeature]FailoverFeature" 
        } 
WindowsFeature RSATClusteringCmdInterface 
        { 
            Ensure = "Present" 
            Name   = "RSAT-Clustering-CmdInterface" 
 
            DependsOn = "[WindowsFeature]RSATClusteringPowerShell" 
        }  
        

WindowsFeature RSAT-Clustering-Mgmt {
 
                    Name = 'RSAT-Clustering-Mgmt'
                    Ensure = 'Present'
                    
                } 
        
             


WindowsFeature RSAT-ADDS-Tools {
 
                    Name = 'RSAT-ADDS-Tools'
                    Ensure = 'Present'

 
                }

WindowsFeature RSAT-ADDS {
 
                    Name = 'RSAT-ADDS'
                    Ensure = 'Present'

                }

WindowsFeature RSAT-AD-Tools {
 
                    Name = 'RSAT-AD-Tools'
                    Ensure = 'Present'

                }
                                
WindowsFeature RSAT-AD-Toolsa {
 
                    Name = 'RSAT-AD-PowerShell'
                    Ensure = 'Present'
                    
                }

## Joining CLuster

xWaitForCluster waitForCluster 
        { 
            Name = $Node.ClusterName 
            RetryIntervalSec = 10 
            RetryCount = 60 
 
            DependsOn = “[WindowsFeature]RSATClusteringCmdInterface”,“[WindowsFeature]RSATClusteringPowerShell"  
        } 
 
xCluster joinCluster 
        { 
            Name = $Node.ClusterName 
            StaticIPAddress = $Node.ClusterIPAddress 
            DomainAdministratorCredential = $domainCred 
 
            DependsOn = "[xWaitForCluster]waitForCluster" 
        }   


}


Node $AllNodes.Where({$_.MachineName -eq'S2'}).nodename {

  

## 2.Config of LCM

 LocalConfigurationManager {
           
            RebootNodeIfNeeded = $true
            ConfigurationMode = "ApplyAndAutoCorrect"
            
                            }

## 3.Config  DNS 

xDNSServerAddress SetDNS {
            Address = $Node.DNSAddress
            InterfaceAlias = $Node.InterfaceAlias
            AddressFamily = $Node.AddressFamily
            DependsOn = "[xComputer]SetName"
        }

##  Testing Ip Address 


xIPAddress  newIp {

InterfaceAlias = $Node.InterfaceAlias
IPAddress = $node.IPAddress
AddressFamily = $Node.AddressFamily
SubnetMask = 24
DefaultGateway = $node.DefaultGateway
DependsOn = "[xComputer]SetName"


}


## 4.Config  Name 
xComputer SetName { 
          Name = $Node.MachineName
          DomainName = "marioo.com"
          Credential = $domainCred 

        }
## 5. Setting up Domain Controller


## 6.Installing WindowsFeature

WindowsFeature FailoverFeature 
        { 
            Ensure = "Present" 
            Name      = "Failover-clustering" 
        }
        
        
WindowsFeature RSATClusteringPowerShell 
        { 
            Ensure = "Present" 
            Name   = "RSAT-Clustering-PowerShell"    
 
            DependsOn = "[WindowsFeature]FailoverFeature" 
        } 
WindowsFeature RSATClusteringCmdInterface 
        { 
            Ensure = "Present" 
            Name   = "RSAT-Clustering-CmdInterface" 
 
            DependsOn = "[WindowsFeature]RSATClusteringPowerShell" 
        }         



WindowsFeature RSAT-ADDS-Tools {
 
                    Name = 'RSAT-ADDS-Tools'
                    Ensure = 'Present'
                   
                }

WindowsFeature RSAT-ADDS {
 
                    Name = 'RSAT-ADDS'
                    Ensure = 'Present'

                }

WindowsFeature RSAT-AD-Tools {
 
                    Name = 'RSAT-AD-Tools'
                    Ensure = 'Present'
                    
                }

                
WindowsFeature RSAT-AD-Toolsa {
 
                    Name = 'RSAT-AD-PowerShell'
                    Ensure = 'Present'
                    
                }





WindowsFeature RSAT-Clustering-Mgmt {
 
                    Name = 'RSAT-Clustering-Mgmt'
                    Ensure = 'Present'
                    
                } 

## seting Up Cluster 

xCluster ensureCreated 
        { 
            Name = $Node.ClusterName 
            StaticIPAddress = $Node.ClusterIPAddress 
            DomainAdministratorCredential = $domainCred 
            DependsOn = “[WindowsFeature]RSATClusteringCmdInterface” 
       } 
                                                          }

Node $AllNodes.Where({$_.MachineName -eq'S3'}).nodename {

  

## 2.Config of LCM

 LocalConfigurationManager {
           
            RebootNodeIfNeeded = $true
            ConfigurationMode = "ApplyAndAutoCorrect"
            
                            }

## 3.Config  DNS 

xDNSServerAddress SetDNS {
            Address = $Node.DNSAddress
            InterfaceAlias = $Node.InterfaceAlias
            AddressFamily = $Node.AddressFamily
            DependsOn = "[xComputer]SetName"
        }

##  Testing Ip Address 


xIPAddress  newIp {

InterfaceAlias = $Node.InterfaceAlias
IPAddress = $node.IPAddress
AddressFamily = $Node.AddressFamily
SubnetMask = 24
DefaultGateway = $node.DefaultGateway
DependsOn = "[xComputer]SetName"


}


## 4.Config  Name 
xComputer SetName { 
          Name = $Node.MachineName
          DomainName = "marioo.com"
          Credential = $domainCred 

        }
## 5. Setting up Domain Controller


## 6.Installing WindowsFeature

WindowsFeature FailoverFeature 
        { 
            Ensure = "Present" 
            Name      = "Failover-clustering" 
        }
        
        
WindowsFeature RSATClusteringPowerShell 
        { 
            Ensure = "Present" 
            Name   = "RSAT-Clustering-PowerShell"    
 
            DependsOn = "[WindowsFeature]FailoverFeature" 
        } 
WindowsFeature RSATClusteringCmdInterface 
        { 
            Ensure = "Present" 
            Name   = "RSAT-Clustering-CmdInterface" 
 
            DependsOn = "[WindowsFeature]RSATClusteringPowerShell" 
        }         



WindowsFeature RSAT-ADDS-Tools {
 
                    Name = 'RSAT-ADDS-Tools'
                    Ensure = 'Present'
                   
                }

WindowsFeature RSAT-ADDS {
 
                    Name = 'RSAT-ADDS'
                    Ensure = 'Present'

                }

WindowsFeature RSAT-AD-Tools {
 
                    Name = 'RSAT-AD-Tools'
                    Ensure = 'Present'
                    
                }

                
WindowsFeature RSAT-AD-Toolsa {
 
                    Name = 'RSAT-AD-PowerShell'
                    Ensure = 'Present'
                    
                }





WindowsFeature RSAT-Clustering-Mgmt {
 
                    Name = 'RSAT-Clustering-Mgmt'
                    Ensure = 'Present'
                    
                } 

## Joining Cluster

xWaitForCluster waitForCluster 
        { 
            Name = $Node.ClusterName 
            RetryIntervalSec = 10 
            RetryCount = 60 
 
            DependsOn = “[WindowsFeature]RSATClusteringCmdInterface”,“[WindowsFeature]RSATClusteringPowerShell"  
        } 
 
xCluster joinCluster 
        { 
            Name = $Node.ClusterName 
            StaticIPAddress = $Node.ClusterIPAddress 
            DomainAdministratorCredential = $domainCred 
 
            DependsOn = "[xWaitForCluster]waitForCluster" 
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
            NodeName = 'DC01'
            MachineName = 'S1'
            DomainName = 'marioo.com'
            IPAddress = '192.168.233.11'
            InterfaceAlias = 'Ethernet'
            DefaultGateway = '192.168.233.50'
            SubnetMask = '24'
            AddressFamily = 'IPv4'
            DNSAddress = '192.168.233.1','8.8.8.8'
            ClusterIPAddress = '192.168.233.100'
            ClusterName = 'MainCluster'
}

@{
            NodeName = 'DC02'
            MachineName = 'S2'
            DomainName = 'marioo.com'
            IPAddress = '192.168.233.12'
            InterfaceAlias = 'Ethernet'
            DefaultGateway = '192.168.233.50'
            SubnetMask = '24'
            AddressFamily = 'IPv4'
            DNSAddress = '192.168.233.1','8.8.8.8'
            ClusterIPAddress = '192.168.233.100'
            ClusterName = 'MainCluster'
}

@{
            NodeName = 'DC03'
            MachineName = 'S3'
            DomainName = 'marioo.com'
            IPAddress = '192.168.233.13'
            InterfaceAlias = 'Ethernet'
            DefaultGateway = '192.168.233.50'
            SubnetMask = '24'
            AddressFamily = 'IPv4'
            DNSAddress = '192.168.233.1','8.8.8.8'
            ClusterIPAddress = '192.168.233.100'
            ClusterName = 'MainCluster'
}




           
);
               } 


$cred = Get-Credential

newserver -ConfigurationData $DevConfig -domainCred $cred -OutputPath "C:\Users\Administrator\Desktop\Config"



Set-DscLocalConfigurationManager -Path "C:\Users\Administrator\Desktop\Config" -Credential $cred -Verbose 


Start-DscConfiguration "C:\Users\Administrator\Desktop\Config" -Credential $cred -Wait  -Verbose -Force