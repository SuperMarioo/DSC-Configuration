mkdir c:\PullServer





$paramhash = @{


name = "DSCCONFIG"
path = "c:\PullServer"
fullaccess = "Supermario\Domain Admins"
ReadAccess = "Everyone"


}

New-SmbShare @paramhash


Get-WindowsFeature dsc-service | Install-WindowsFeature


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





Get-DscResource | where path -Match "^c:\\program files\\WindowsPowershell\\Modules" | 
select -ExpandProperty module -Unique | foreach `
{

$out = "{0}_{1}.zip" -f $_.Name , $_.version

$zip = Join-Path  "c:\PullServer" -ChildPath $out

Zip-Directory -DestinationFileName $zip -SourceDirectory $_.modulebase 

Start-Sleep -Seconds 2 

if($zip) {



New-DSCCheckSum -ConfigurationPath $zip -ErrorAction SilentlyContinue



}

}





Join-Path "c:\PullServer" -ChildPath "nice"