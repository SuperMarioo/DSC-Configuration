



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


 Import-DscResource -Module xActiveDirectory, xComputerManagement, xNetworking,xDhcpServer 


Node $AllNodes.nodename {


##Config of LCM

 LocalConfigurationManager {
           
            RebootNodeIfNeeded = $true
            
                            }



xComputer SetName { 
          Name = $Node.MachineName 


        }



xDNSServerAddress SetDNS {
            Address = $Node.DNSAddress
            InterfaceAlias = $Node.InterfaceAlias
            AddressFamily = $Node.AddressFamily
        }

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
 


xADDomain FirstDC {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeCred
            DependsOn = '[xComputer]SetName', '[WindowsFeature]ADDSInstall'
        }    
    
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