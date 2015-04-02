configuration PullServer
{
        
param(

[string]$guid,
[System.Management.Automation.Credential()]$credential = [System.Management.Automation.PSCredential]




)        
        
        
        
        Import-DscResource -ModuleName   xtimezone, xnetworking
        

    node $Allnodes.Where({$_.dupa -eq "dc01"}).nodename
    
    {


    xtimezone Eastern {


    TimeZone = "Pacific Standard Time"

    }



    group MyDemo {


    GroupName = "Nice"
    Description = = "sialalal"
    Ensure = "Present"
    Credential = $credential
    MembersToInclude = "Supermario\MariuszS"



    }

      
     xDNSServerAddress YOYODNS {
    
     Address = "192.168.233.100","8.8.8.8"
     InterfaceAlias = "internal"
     AddressFamily = "IPv4"
     
     
     }  


  



     LocalConfigurationManager {

     AllowModuleOverwrite = $true
     ConfigurationID = $guid
     ConfigurationMode = "ApplyandMonitor"
     RefreshMode = "Pull"
     DownloadManagerName = "DscFileDownloadManager"
     DownloadManagerCustomData =  @{sourcepath = "\\DC01\PullServer"}
     CertificateID  = $node.thumbprint

     } #lcm

      
    }
  
  
    node $allnodes.Where({$_.dupa -eq "windows8"}).nodename
    {
      
        
        
        

      

}

      
    }

    
$configdata = @{
AllNodes = @(
@{
NodeName="*"
path = "c:\lolita.zip"
};
@{
NodeName="DC01"
dupa = 'DC01'
Certificatefile = "C:\mycert.cer"
Thumbprint = "38BA053E79A8BA88C25A25DA60A111B5907958BB"
};
@{
NodeName="windows8"

Destination = 'C:\TUTAJ\'
dupa = 'dc01'
};
);
}






## Need Giud

$guid = [guid]::NewGuid().guid


## Genereting Mof Files

$paramhash = @{
guid = $guid
credential = "Supermario\Mariusz"
OutputPath = "C:\try"
ConfigurationData = $configdata
verbose = $true

}

## Genereting Mof Files

PullServer @paramhash






Start-DscConfiguration c:\try\ -Wait -Force -Verbose
