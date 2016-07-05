#requires -Modules Pester
#requires -Version 2
#requires -PSSnapin VMware.VimAutomation.Core
<#
    Script Name: check_cluster.ps1
    Author: Tim Hynes
    Version: 0.a
    Description: This script checks the configuration of a vSphere cluster using Pester tests
#>
# Import our VMware automation module
Import-Module -Name VMware.VimAutomation.Core
# Set up variables
## NOTE: I put my credentials in a seperate file here so I can read them in, possibly not the best solution, but means I can make the script public
. '.\vmware_creds.ps1'
# Pester expected outcomes
## Cluster settings
### HA Settings
$haenabled = $false
$haacenabled = $true
$haisolation = 'DoNothing'
### DRS Settings
$drsmode = 'FullyAutomated'
$drsenabled = $false
### VM swap file policy
$clus_swap = 'WithVM'
# Connect to vCenter server
Connect-VIServer -Server $vc_ip -Credential $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($vc_user, $(ConvertTo-SecureString -String $vc_pass -AsPlainText -Force)))
# Pester tests
## Cluster settings
### HA settings
Describe -Name 'Cluster Configuration: HA Settings' -Fixture {
  foreach ($cluster in (Get-Cluster))
  {
    It -name "$($cluster.name) Cluster HA Enabled" -test {
      $value = (Get-Cluster $cluster).HAEnabled
      try 
      {
        $value | Should Be $haenabled
      }
      catch 
      {
        Write-Warning -Message "Fixing $cluster - $_"
        Set-Cluster -Cluster $cluster -HAEnabled:$haenabled -Confirm:$false
      }
    }
    It -name "$($cluster.name) Cluster HA Admission Control" -test {
      $value = (Get-Cluster $cluster).HAAdmissionControlEnabled
      try 
      {
        $value | Should Be $haacenabled
      }
      catch 
      {
        Write-Warning -Message "Fixing $cluster - $_"
        Set-Cluster -Cluster $cluster -HAAdmissionControlEnabled:$haacenabled -Confirm:$false
      }
    }
    It -name "$($cluster.name) Cluster HA Isolation Response" -test {
      $value = (Get-Cluster $cluster).HAIsolationResponse
      try 
      {
        $value | Should Be $haisolation
      }
      catch 
      {
        Write-Warning -Message "Fixing $cluster - $_"
        Set-Cluster -Cluster $cluster -HAIsolationResponse:$haisolation -Confirm:$false
      }
    }
  }
}
### DRS settings
Describe -Name 'Cluster Configuration: DRS Settings' -Fixture {
  foreach ($cluster in (Get-Cluster))
  {
    It -name "$($cluster.name) Cluster DRS Mode" -test {
      $value = (Get-Cluster $cluster).DrsAutomationLevel
      try 
      {
        $value | Should Be $drsmode
      }
      catch 
      {
        Write-Warning -Message "Fixing $cluster - $_"
        Set-Cluster -Cluster $cluster -DrsAutomationLevel:$drsmode -Confirm:$false
      }
    }
    It -name "$($cluster.name) Cluster DRS Enabled" -test {
      $value = (Get-Cluster $cluster).DrsEnabled
      try 
      {
        $value | Should Be $drsenabled
      }
      catch 
      {
        Write-Warning -Message "Fixing $cluster - $_"
        Set-Cluster -Cluster $cluster -DrsEnabled:$drsenabled -Confirm:$false
      }
    }
  }
}
### VM Swap File Policy
Describe -Name 'Cluster Configuration: VM Swap File Policy Settings' -Fixture {
  foreach ($cluster in (Get-Cluster))
  {
    It -name "$($cluster.name) VM Swap File Location Policy" -test {
      $value = (Get-Cluster $cluster).VMSwapfilePolicy
      try 
      {
        $value | Should Be $clus_swap
      }
      catch 
      {
        Write-Warning -Message "Fixing $cluster - $_"
        Set-Cluster -Cluster $cluster -VMSwapfilePolicy:$clus_swap -Confirm:$false
      }
    }
  }
}
# Disconnect from vCenter server
Disconnect-VIServer -Server * -Confirm:$false