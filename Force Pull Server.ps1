function Force-PullServer {

param (
[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
[string]$computername



)


Invoke-Command -ComputerName $computername -ScriptBlock {


(Get-ScheduledTask).where({$_.taskname -eq "Consistency"}) | Start-ScheduledTask 


}



}



"windows8","server1" | ?   { Force-PullServer $_ }