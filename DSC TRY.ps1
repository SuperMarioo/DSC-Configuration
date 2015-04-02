configuration PullServer
{ 
        
param(

[string]$guid


)        
        
        
        
        Import-DscResource -ModuleName   xtimezone, xnetworking,cFileShare
        
    node $Allnodes.nodename
    
    {


    cCreateFileShare test {
    
    ShareName = "Hello"
    Path = "E:\"
    Ensure = "Present"
    
    
    
    
    } 





    xtimezone Eastern {


    TimeZone = "Eastern Standard Time"

    }





      
     xDNSServerAddress YOYODNS {
    
     Address = "192.168.233.100","8.8.8.8"
     InterfaceAlias = "internal"
     AddressFamily = "IPv4"
     
     
     } 
     
  
      


  

  

  <#   LocalConfigurationManager {

     AllowModuleOverwrite = $true
     ConfigurationID = $guid
     ConfigurationMode = "ApplyandMonitor"
     RefreshMode = "Pull"
     DownloadManagerName = "DscFileDownloadManager"
     DownloadManagerCustomData =  @{
     SourcePath  = "\\Dc01\dscconfig"}
     

     } #lcm
#>
     
    }
  
  
      
    }

    
$configdata = @{
AllNodes = @(

@{
NodeName="DC01"
};

);
}


configuration LCM {

node dc01 {

LocalConfigurationManager {

RefreshMode = "Pull"


}


}

}


LCM -OutputPath c:\try\
## Need Giud

$guid = [guid]::NewGuid().guid


## Genereting Mof Files

$paramhash = @{

OutputPath = "C:\try"
ConfigurationData = $configdata
verbose = $true

}

## Genereting Mof Files
`
PullServer @paramhash
 

Set-DSCLocalConfigurationManager c:\try\ -CimSession  $session
get-DSCLocalConfigurationManager

Start-DscConfiguration C:\try -Wait -Force -Verbose


$src  = "C:\try\windows8.mof"
$dst = Join-Path -Path "\\dc01\dscconfig" -ChildPath "468f2def-f627-440c-ae4b-e934c8c96e0a.mof"

Copy-Item -Path $src -Destination $dst -PassThru 
New-DSCCheckSum $dst 


$session = New-CimSession -ComputerName windows8 