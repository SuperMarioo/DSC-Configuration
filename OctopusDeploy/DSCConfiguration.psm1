configuration DSC
{
   param (
        [Parameter(Mandatory)]
        [System.Collections.IDictionary] $OctopusParameters
    )



       
  
    node ("localhost")
    {

$service = $OctopusParameters['Service'] -split ","

$state = $OctopusParameters['state'] -split ","

$StartupType = $OctopusParameters['StartupType'] -split ","

$secpasswd = ConvertTo-SecureString $OctopusParameters['password'] -AsPlainText -Force

$credantials = New-Object System.Management.Automation.PSCredential ($OctopusParameters['UserName'], $secpasswd)
    
    ## Configuring Services
    
    for ($i = 0; $i -lt $StartupType.count ; $i++)
{ 
   
   
    Service $service[$i] {
        Credential = $credantials
        Name = $service[$i]
        State = $state[$i]
        StartupType = $StartupType[$i]
     
     }

    
}
     

     ## Windows Features for IIS




            WindowsFeature AspDotNet45Core
            {
                Name   = 'Net-Framework-45-ASPNET'
                Ensure = 'Present'
            }

            WindowsFeature IIS
            {
                Name      = 'Web-Server'
                Ensure    = 'Present'
                DependsOn = '[WindowsFeature]AspDotNet45Core'
                
            }

            WindowsFeature IISAdmin
            {
                Name      = 'Web-Mgmt-Console'
                Ensure    = 'Present'
                DependsOn = '[WindowsFeature]IIS'
            }

            WindowsFeature AspDotNet45
            {
                Name      = 'Web-Asp-Net45'
                Ensure    = 'Present'
                DependsOn = '[WindowsFeature]IIS'
            }

            WindowsFeature IsapiExtensions
            {
                Name      = 'Web-ISAPI-Ext'
                Ensure    = 'Present'
                DependsOn = '[WindowsFeature]IIS'
            }

            WindowsFeature IsapiFilters
            {
                Name      = 'Web-ISAPI-Filter'
                Ensure    = 'Present'
                DependsOn = '[WindowsFeature]IIS'
            }

            WindowsFeature DotNetExtensibility45
            {
                Name      = 'Web-Net-Ext45'
                Ensure    = 'Present'
                DependsOn = '[WindowsFeature]IIS'
            }


## Disiabling ENC for IE 

            Registry DisableESCAdmin{


            Key = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
            ValueName = "IsInstalled"
            ValueData = $OctopusParameters['IEAdmin']
            ValueType = "Dword"
           


            }  
            
                   Registry DisableESCUser{


            Key = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
            ValueName = "IsInstalled"
            ValueData = $OctopusParameters['IEUser']
            ValueType = "Dword"
           


            }   



     
            
    }
}

