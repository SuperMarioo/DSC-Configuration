$mywsman = dir WSMan:\localhost\Client\TrustedHosts

$newserver = "DC01"
$hash = @{


path = "WSMan:\localhost\Client\TrustedHosts"

force = $true


}


if ($mywsman.value) {


$hash.add("value","$($mywsman.value),$newserver")



}else {

$hash.add("value",$newserver)

}

Set-Item @hash

$psdrive = @{ 

name ="Newpsdriveserver"
PSprovider = "FileSystem"
root = "\\$newserver\C$\Program Files\WindowsPowerShell\Modules"

}

New-PSDrive @psdrive




$a = "C:\Program Files\WindowsPowerShell\Modules\*"
$b = "Newpsdriveserver:\"

$param1 = @{

path = $a
Destination = $b
container = $true
force = $true
recurse = $true
passthru = $true

}

Copy-Item @param1


