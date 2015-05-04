



## Setting up WSMAN Trusted Host and Copying DSC Resouces


function Setting-Connection {

 [CmdletBinding()]
                               [OutputType([int])]
  Param
  (
  [Parameter(Mandatory=$true,
  Position=0)]
  [string]$Computername,
  [PSCredential]$Credential
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


$hash.add("value","$newserver")



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

New-PSDrive @psdrive -Credential $Credential




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

          [Parameter(Mandatory)] 
        [pscredential]$userpassword,
 
        [pscredential]$Credential
    )


 Import-DscResource -Module xChrome,xActiveDirectory, xComputerManagement, xNetworking,xDhcpServer,xDisk,cSmbShare,xwindowsupdate

Node $AllNodes.nodename {

## 1.Authorizing DHCP SERVER , Adding DHCP Groups to AD  and Fixing server manager error
Script ScriptExample
{
    SetScript = { 
        Add-DhcpServerInDC (Get-ADDomainController).hostname -IPAddress (Get-ADDomainController).IPv4Address

        Add-DHCPServerSecurityGroup  

        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12 -Name ConfigurationState -Value 2

        Restart-Service -Name DHCPServer -Force
        
    }
    TestScript = { 
    
    If (get-DhcpServerInDC) { return $true} else {return $false}
    
    
    
     }
    GetScript = { [string]$nice = (dir "C:\DSC-C1ONFIG" -ErrorAction SilentlyContinue | select name)[0].name 
    
    
    
    return @{

      GetScript = $GetScript
      SetScript = $SetScript
      TestScript = $TestScript
      Result = if($nice){"yo"}else{"niewiem"}

    }

    
    
     }
     
     
    DependsOn = "[WindowsFeature]DHCP","[WindowsFeature]RSAT-DHCP"
     
     
        }          

## 2.Config of LCM

 LocalConfigurationManager {
           
            RebootNodeIfNeeded = $true
            ConfigurationMode = "ApplyOnly"
            
                            }

## 3.Config  DNS 

xDNSServerAddress SetDNS {
            Address = $Node.DNSAddress
            InterfaceAlias = $Node.InterfaceAlias
            AddressFamily = $Node.AddressFamily
            DependsOn = "[xComputer]SetName"
        }

##  Testing Ip Address 
 
  MSFT_xChrome chrome {
    
    LocalPath = "c:\Chrome\"
    Language = "English"



 }


xIPAddress  newIp {

InterfaceAlias = $Node.InterfaceAlias
IPAddress = "192.168.233.1"
AddressFamily = $Node.AddressFamily
SubnetMask = 24
DefaultGateway = "192.168.233.1"
DependsOn = "[xComputer]SetName"


}



## 4.Config  Name 
xComputer SetName { 
          Name = $Node.MachineName 

        }
## 5. Setting up Domain Controller
WindowsFeature ADDSInstall {
            Ensure = 'Present'
            Name = 'AD-Domain-Services'
            DependsOn = "[xComputer]SetName","[xDNSServerAddress]SetDNS","[xIPAddress]newIp"
        }






## Adding Users 

xADUser Mariusz {

        DomainName = $Node.DomainName
        DomainAdministratorCredential = $domainCred
        UserName = "Mariusz"
        Password = $userpassword
        Ensure = "present"


}

xADUser Chris {

        DomainName = $Node.DomainName
        DomainAdministratorCredential = $domainCred
        UserName = "Chris"
        Password = $userpassword
        Ensure = "present"
 

}



## 6.Installing WindowsFeature

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

WindowsFeature RSAT-AD-AdminCenter {
 
                    Name = 'RSAT-AD-AdminCenter'
                    Ensure = 'Present'

                }

WindowsFeature DHCP {
            Ensure = 'present'
            Name = 'DHCP'
            IncludeAllSubFeature = $true

        }

WindowsFeature RSAT-DHCP {
 
                    Name = 'RSAT-DHCP'
                    Ensure = 'Present'
                    DependsOn = "[WindowsFeature]DHCP"
                }

WindowsFeature FileAndStorage-Services  {
 
                    Name = 'FileAndStorage-Services'
                    Ensure = 'Present'
                    IncludeAllSubFeature = $true
                    DependsOn = "[WindowsFeature]DHCP"
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


## 7.Seting up DHCP 
xDhcpServerScope DC01MainScope {

        Name = 'DC01'
        LeaseDuration = '00:08:00'
        State = 'Active'
        AddressFamily = 'IPv4'
        IPStartRange = '192.168.233.1'  
        IPEndRange = '192.168.233.254'
        SubnetMask = '255.255.255.0'
        Ensure = 'present'
        DependsOn = "[WindowsFeature]DHCP"
}
    
xDhcpServerOption DC01MainScopeOption {


        Ensure = 'present' 
        ScopeID = '192.168.233.0'
        DnsDomain = 'mario.com' 
        DnsServerIPAddress = '192.168.233.27'
        AddressFamily = 'IPv4'
        DependsOn = "[WindowsFeature]DHCP","[xDhcpServerScope]DC01MainScope" 
}

xDhcpServerScope Vlan20Scope {

        Name = 'Vlan20'
        LeaseDuration = '00:08:00'
        State = 'Active'
        AddressFamily = 'IPv4'
        IPStartRange = '192.168.168.1'  
        IPEndRange = '192.168.168.254'
        SubnetMask = '255.255.255.0'
        Ensure = 'present'
        DependsOn = "[WindowsFeature]DHCP"
}

xDhcpServerOption Vlan20ScopeOpitons {


        Ensure = 'present' 
        ScopeID = '192.168.168.0'
        DnsDomain = 'Vlan20.com' 
        DnsServerIPAddress = '192.168.168.27'
        AddressFamily = 'IPv4'
        DependsOn = "[WindowsFeature]DHCP","[xDhcpServerScope]Vlan20Scope" 
}

xDhcpServerReservation DC01MainScopeReservation {


    ClientMACAddress = "00155D000A06"
    ScopeID = '192.168.233.0'
    IPAddress = "192.168.233.145"
    AddressFamily = 'IPv4'
    Ensure = "Present"
    Name = "Windows7 Machine"
    DependsOn = "[xDhcpServerScope]DC01MainScope"

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
            NodeName = 'DC1'
            MachineName = 'DC1'
            DomainName = 'mario.com'
            IPAddress = '192.168.233.1'
            InterfaceAlias = 'Ethernet 2'
            DefaultGateway = '192.168.233.50'
            SubnetMask = '24'
            AddressFamily = 'IPv4'
            DNSAddress = '127.0.0.1','8.8.8.8'
}
           
);
               } 


newserver -ConfigurationData $DevConfig   -OutputPath "C:\New Server DSC" -userpassword $user -Credential $cred -domainCred $cred -safemodeCred $cred 




$user = Get-Credential
$cred = Get-Credential




Set-DscLocalConfigurationManager -Path "C:\New Server DSC" -Credential $cred -Verbose 

Start-DscConfiguration "C:\New Server DSC"  -Credential $cred -Wait  -Verbose -Force

Test-DscConfiguration -CimSession $session  -Verbose


$session = New-CimSession -Credential $cred -ComputerName "dc01" 