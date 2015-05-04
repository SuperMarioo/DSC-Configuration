
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
   @{
 NodeName='windows7'
 Ensure = 'present'
 name = 'windows7'
 Guid = [guid]::NewGuid().guid
 }


 )



}




Configuration SmbPullServer {
 


 
Import-DscResource -ModuleName xHyper-V , xWindowsUpdate,xTimeZone,csmbshare,hostsfile,RecylceBin,xDisk,cFileShare,cFolderQuota,xnetworking


 
 Node $AllNodes.Where({$_.name -eq'server1'}).nodename {

 



## Testing cVSS Resource ,

<#

cVSS Enable-shadowCopy {

     Drive = 'C:'
          Enable = $true
          StorageLocation = 'C:'
          MaxSize = '2048MB'
          


}

cVSSTaskScheduler SevenAM{
          TaskName = "ShadowCopyVolume7AM"
          Ensure = "absent"
          Drive = "C:"
          TriggerTime = "3:33PM"
      }


 cVSSTaskScheduler NineAM{
           TaskName = "ShadowCopyVolume9AM"
           Ensure = "absent"
           Drive = "C:"
           TriggerTime = "3:35PM"
       }
      
cVSSTaskScheduler Noon{
           TaskName = "ShadowCopyVolumeNoon"
           Ensure = "absent"
           Drive = "C:"
           TriggerTime = "3:37PM"

}

## Testing Script Resource 

 
#>


Script ScriptExample
{
    SetScript = { 
        $sw = New-Object System.IO.StreamWriter("C:\TestFile.txt")
        $sw.WriteLine("Some sample string")
        $sw.Close()
    }
    TestScript = { If (Test-Path "C:\TestFile.txt") { return $true} else {return $false} }
    GetScript = { [string]$nice = (dir "C:\DSC-CONFIG" | select name)[0].name
    
    
    
    return @{

      GetScript = $GetScript
      SetScript = $SetScript
      TestScript = $TestScript
      Result = $nice

    }
    
    
     }   }          
    


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
   FolderEnumerationMode = "AccessBased"

            } 

          cSmbShare  Client {

   Name = 'Client'
   Path = 'K:\'
   Ensure = 'present'
   ReadAccess = 'everyone'
   FolderEnumerationMode = "AccessBased"
 
 
            }


          cSmbShare  PullServer {

   Name = 'PullServer'
   Path = 'W:\'
   Ensure = 'present'
   Description = "PullServer"
   FullAccess = 'SUPERMARIO\Administrator','SUPERMARIO\Mario'
   ReadAccess = 'everyone','SUPERMARIO\MariuszS'
   EncryptData = $false
   FolderEnumerationMode = 'AccessBased'

   
   
            }

          cSmbShare  Users {

   Name = 'Users'
   Path = 'G:\'
   Ensure = 'present'
   ReadAccess = 'SUPERMARIO\MarianG','SUPERMARIO\ElaineJ'
   
 
   
   
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
          Ensure = 'PRESENT'
          ReadAccess = 'everyone'
          FolderEnumerationMode = 'AccessBased'


             }

## 5. New Test Share1


          cSmbShare DSC_CONFIG {


          Name = "DSC-CONFIG"
          Path = "C:\DSC-CONFIG"
          Ensure = 'PRESENT'
          ReadAccess = 'everyone'
          FolderEnumerationMode = 'AccessBased'


             } 

## 6. Assigning Quotas

    cFolderQuota London {

        Path = 'K:\London'
        Ensure = 'present'
        Template = 'London'
        Subfolders = $true
        

                           }

                              
        cFolderQuota 'New York' {

        Path = 'K:\New York'
        Ensure = 'present'
        Template = 'New York'
        Subfolders = $true
        DependsOn = '[cQuotaTemplate]NewYork'

                             }

        cFolderQuota 'Single Folder' {

        Path = 'K:\Single Folder' 
        Ensure = 'present'
        Template = 'Generic'
        Subfolders = $false
        DependsOn = '[cQuotaTemplate]Generic'

                             }

                             
        cFolderQuota 'Drive' {

        Path = 'w:\'
        Ensure = 'present'
        Template = 'Generic'
        Subfolders = $false
        DependsOn = '[cQuotaTemplate]Generic'

                             }

         cFolderQuota 'Warsaw' {

        Path = 'K:\Warsaw'
        Ensure = 'present'
        Template = 'Monitor 500 MB Share'
        Subfolders = $true
        DependsOn = '[cQuotaTemplate]Generic'

                             }

        cFolderQuota 'test' {

        Path = 'C:\Scripts'
        Ensure = 'present'
        Template = 'Generic'
        Subfolders = $true
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
        

        }



         cQuotaTemplate Generic {

        Name = 'Generic'
        Size = 10GB
        Description = 'User Template'
        MailTo = 'Owner'
        Percentage = 78
        Ensure = 'present'
        SoftLimit =$true
        

        }
        #>


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
 Address = "192.168.233.10","8.8.8.8"
 AddressFamily = "Ipv4"


 }

 xHotfix DSCUpdate {


            Ensure = "Present" 
            Path = "\\server1\client\Windows8.1-KB3000850-x64.msu" 
            Id = "KB3000850"


 }





    }

 <#Node $AllNodes.Where({$_.name -eq'windows7'}).nodename {


 
xTimeZone TimeZoneExample
        {
            TimeZone = "Pacific Standard Time"
        }





    }
    
}#>

}


SmbPullServer  -ConfigurationData $myconfig -OutputPath "C:\DSC-CONFIG"


Publish-MrMOFToSMB  "C:\DSC-CONFIG" 


Update-DscConfiguration -Wait 

break ;



Configuration SmbPullServerLCM {
 

 

 
 Node $AllNodes.Where({$_.name -eq'server1'}).nodename {
 
 


 LocalConfigurationManager {


     AllowModuleOverwrite = $true
     ConfigurationID = $node.guid
     ConfigurationMode = "ApplyAndAutoCorrect"
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
     ConfigurationMode = "ApplyAndAutoCorrect"
     RefreshMode = "Pull"
     DownloadManagerName = "DscFileDownloadManager"
     DownloadManagerCustomData =  @{
     SourcePath  = "\\server1\PullServer"}



 }




    }  

 Node $AllNodes.Where({$_.name -eq'windows7'}).nodename {


  LocalConfigurationManager {


     AllowModuleOverwrite = $true
     ConfigurationID = $node.guid
     ConfigurationMode = "ApplyAndAutoCorrect"
     RefreshMode = "Pull"
     DownloadManagerName = "DscFileDownloadManager"
     DownloadManagerCustomData =  @{
     SourcePath  = "\\server1\PullServer"}



 }




    }



}



SmbPullServerLCM -ConfigurationData $myconfig -OutputPath "C:\DSC-LCMCONFIG"

Set-DscLocalConfigurationManager -Path "C:\DSC-LCMCONFIG"  -Verbose




function Publish-MrMOFToSMB {

<#
.SYNOPSIS
    Publishes a DSC MOF configuration file to the pull server that's configured on a target node(s).
 
.DESCRIPTION
    Publish-MrMOFToSMB is an advanced PowerShell function that publishes one or more MOF configuration files
    to the an SMB DSC server by determining the ConfigurationID (GUID) that's configured on the target node along
    with the UNC path of the SMB pull server and creates the necessary checksum along with copying the MOF and
    checksum to the pull server.
 
.PARAMETER ConfigurationPath
    The folder path on the local computer that contains the mof configuration files.

.PARAMETER ComputerName
    The computer name of the target node that the DSC configuration is created for.
 
.EXAMPLE
     Publish-MrMOFToSMB -ConfigurationPath 'C:\MyMofFiles'

.EXAMPLE
     Publish-MrMOFToSMB -ConfigurationPath 'C:\MyMofFiles' -ComputerName 'Server01', 'Server02'

.EXAMPLE
     'Server01', 'Server02' | Publish-MrMOFToSMB -ConfigurationPath 'C:\MyMofFiles'

.EXAMPLE
     MyDscConfiguration -Param1 Value1 -Parm2 Value2 | Publish-MrMOFToSMB
 
.INPUTS
    String
 
.OUTPUTS
    None
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [Alias('Directory')]
        [string]$ConfigurationPath,

        [Parameter(ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [Alias('BaseName')]
        [string[]]$ComputerName
    )


 
    BEGIN {
        if (-not($PSBoundParameters['ComputerName'])) {
            $ComputerName = (Get-ChildItem -Path $ConfigurationPath\*.mof).basename
        }
    }

    PROCESS {
        foreach ($Computer in $ComputerName) {

            try {
                Write-Verbose -Message "Retrieving LCM information from $Computer"
                $LCMConfig = Get-DscLocalConfigurationManager -CimSession $Computer -ErrorAction Stop
            }
            catch {
                Write-Error -Message "An error has occurred. Error details: $_.Exception.Message"
                continue
            }        
            
            $servermof = "$ConfigurationPath\$Computer.mof"

            if (-not(Get-ChildItem -Path $servermof -ErrorAction SilentlyContinue)) {
                Write-Error -Message "Unable to find MOF file for $Computer in location: $ConfigurationPath"
            } 
            elseif ($LCMConfig.RefreshMode -ne 'Pull') {
                Write-Error -Message "The LCM on $Computer is not configured for DSC pull mode."
            }
            elseif ($LCMConfig.DownloadManagerName -ne 'DscFileDownloadManager' -and $LCMConfig.ConfigurationDownloadManagers.ResourceId -notlike '`[ConfigurationRepositoryShare`]*') {
                Write-Error -Message "LCM on $Computer not configured to receive configuration from DSC SMB pull server"
            }
            elseif (-not($LCMConfig.ConfigurationID)) {
                Write-Error -Message "A ConfigurationID (GUID) has not been set in the LCM on $Computer"
            }
            else {
                if ($LCMConfig.ConfigurationDownloadManagers.SourcePath) {
                    $SMBPath = "$($LCMConfig.ConfigurationDownloadManagers.SourcePath)"
                }
                elseif ($LCMConfig.DownloadManagerCustomData.Value) {
                    $SMBPath = "$($LCMConfig.DownloadManagerCustomData.Value)"
                }

                Write-Verbose -Message "Creating DSCChecksum for $servermof"
                New-DSCCheckSum -ConfigurationPath $servermof -Force

                if (Test-Path -Path $SMBPath) {

                    $guidmof = Join-Path -Path $SMBPath -ChildPath "$($LCMConfig.ConfigurationID).mof"

                    try {
                        Write-Verbose -Message "Copying $servermof.checksum to $guidmof.checksum"
                        Copy-Item -Path "$servermof.checksum" -Destination "$guidmof.checksum" -ErrorAction Stop

                        Write-Verbose -Message "Copying $servermof to $guidmof"
                        Copy-Item -Path $servermof -Destination $guidmof -ErrorAction Stop
                    }
                    catch {
                        Write-Error -Message "An error has occurred. Error details: $_.Exception.Message"                    
                    }

                }
                else {
                    Write-Error -Message "Unable to connect to $SMBPath as specified in the LCM on $Computer for it's DSC pull server"
                }
            }
        }
    }
}


Test-DscConfiguration -CimSession windows8 -Verbose
Test-DscConfiguration  -Verbose


## Zip Function
Function New-ZipArchive {

<#
.Synopsis
Create a zip archive from a folder.
.Description
This command will create a zip file from the specified path. The path will be a top level folder in the archive.
.Parameter Path
The top level folder to be archived. This parameter has aliases of PSPath and Source.
.Parameter OutputPath
The filename for the zip file to be created. If it already exists, the command will not run, unless you use -Force. This parameter has aliases of Zip and Target.
.Parameter Force
Delete the existing zip file and create a new one.
.Example
PS C:\> New-ZipArchive -path c:\work -outputpath e:\workback.zip 

Create a new zip file called WorkBack.zip. The top level folder in the archive will be Work.
.Example
PS C:\> $dscres = Get-DSCResource | Select -expandproperty Module -unique | where {$_.path -notmatch "windows\\system32"}
PS C:\> $dscres | foreach {
 $out = "{0}_{1}.zip" -f $_.Name,$_.Version
 $zip = Join-Path -path "E:\DSC\ZipResource" -ChildPath $out
 New-ZipArchive -path $_.ModuleBase -OutputPath $zip -Passthru -force
 }

 The first command gets a unique list of modules for all DSC resources filtering out anything under System32. The second command creates a zip file for each module using the naming format modulename_version.zip.

.Notes
Version      : 1.0
Last Updated : February 2, 2015

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/


  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************

#>

[cmdletbinding(SupportsShouldProcess)]
param(
[Parameter(Position=0,Mandatory,
HelpMessage="Enter the folder path to be archived.")]
[ValidateScript({Test-Path $_})]
[Alias("PSPath","Source")]
[String]$Path,
[Parameter(Position=1,Mandatory,
HelpMessage="Enter the path and filename for the zip file")]
[Alias("zip","Target")]
[ValidateNotNullorEmpty()]
[String]$OutputPath,
[Switch]$Force,
[switch]$Passthru
)

Write-Verbose "Starting $($MyInvocation.Mycommand)"  
Write-Verbose "Using bound parameters:"
Write-verbose  ($MyInvocation.BoundParameters| Out-String).Trim()

if ($Force -AND (Test-Path -path $OutputPath)) {
    Write-Verbose "Testing for existing file and deleting it"
    Remove-Item -Path $OutputPath
}
     
if(-NOT (Test-Path $OutputPath)) {
    Write-Verbose "Creating $OutputPath" 
    Try {
        #create an empty zip file
        Set-Content -path $OutputPath -value ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18)) -ErrorAction Stop
        
        #get the zip file object
        $zipfile = $OutputPath | Get-Item -ErrorAction Stop

        #make sure it is not set to ReadOnly
        write-verbose "Setting isReadOnly to False"
        $zipfile.IsReadOnly = $false  
    }
    Catch {
        Write-Warning "Failed to create $outputpath"
        write-Warning $_.exception.message
        #bail out
        Return
    }
} #if not test zip file path
else {
    Write-Warning "The file $OutputPath already exists. Please delete or use -Force and try again."
    
    #bail out
    Return
}

if ($PSCmdlet.ShouldProcess($Path)) {
    Write-Verbose "Creating Shell.Application"
    $shellApp = New-Object -com shell.application

    Write-Verbose "Using namespace $($zipfile.fullname)" 
    $zipPackage = $shellApp.NameSpace($zipfile.fullname)

    write-verbose ($zipfile | Out-String)

    $target = Get-Item -Path $Path

    $zipPackage.CopyHere($target.FullName) 

    If ($passthru) {
        #Pause enough to give the zip file a chance to update
        Start-Sleep -Milliseconds 200
        Get-Item -Path $Outputpath
    }
} #should process

Write-Verbose "Ending $($MyInvocation.Mycommand)"

}


## Copying DSC Resources and Creating Checksum

Get-DscResource | where path -Match "^c:\\program files\\WindowsPowershell\\Modules" | 
select -ExpandProperty module -Unique | foreach `
{

$out = "{0}_{1}.zip" -f $_.Name , $_.version

$zip = Join-Path  "W:\" -ChildPath $out
New-ZipArchive -path $_.ModuleBase -OutputPath $zip


Start-Sleep -Seconds 2 

if($zip) {



New-DSCCheckSum -ConfigurationPath $zip -ErrorAction SilentlyContinue


}

}