<#
  .SYNOPSIS
  Add or remove the current script folder to/from the list of persistent PowerShell mdoules
   
  Thomas Stensitzki
	
  THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE 
  RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
	
  Version 1.1, 2017-04-05

  Ideas, comments and suggestions to support@granikos.eu 
	
  .DESCRIPTION
	
  This script adds or removes to/from the registry key HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment\PSModulePath 

  Adding the folder to the list of persistent PowerShell module paths is required to provide access across all PowerShell sessions

  .NOTES 
  Requirements 
  - Windows Server 2012/2012 R2
  - Windows Server 2008/2008 R2

  Revision History 
  -------------------------------------------------------------------------------- 
  1.0 | Initial release 
  1.1 | PowerShell hygiene adn some minor typo fixes     

  .PARAMETER Add
  Add the current script folder to the list of persistent PowerShell modules paths	

  .PARAMETER Remove
  Remove the current script folder from the list of persistent PowerShell modules paths	

  .EXAMPLE
  Add the current script folder
  .\Set-PersistentPSModulePath.ps1 -Add

  .EXAMPLE
  Remove the current script folder
  .\Set-PersistentPSModulePath.ps1 -Remove

#>

[CmdletBinding()]
Param(
    [switch]$Add,
    [switch]$Remove
)


$currentPSModulePaths = [string](Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PSModulePath).PSModulePath

$ScriptDir = Split-Path -Path $script:MyInvocation.MyCommand.Path

Write-Host ('Current PSModulePath(s): {0}' -f $currentPSModulePaths)

function Request-Choice {
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][string]$Caption)
    $choices =  [System.Management.Automation.Host.ChoiceDescription[]]@("&Yes","&No")
    [int]$defaultChoice = 1

    $choiceReturn = $Host.UI.PromptForChoice($Caption, "", $choices, $defaultChoice)

    return $choiceReturn   
}

if($Add) {

    if($currentPSModulePaths.Contains($ScriptDir)) {
        Write-Host 'Das aktuelle Skriptverzeichnis wurde bereits in die Variable PSModulePath aufgenommen.'
        Write-Host 'Verwenden Sie Set-PersistentPSModulePath.ps1 -Remove, um den Modulpfad zu entfernen!' 
        exit 0
    }
    
    Write-Host ('Pfad zum Hinzufügen: {0}' -f $ScriptDir)

    if((Request-Choice -Caption 'Möchten Sie den Skriptordner zur persistenten Liste der PowerShell-Module hinzufügen?') -eq 0) {
        
        Write-Host ('Hinzufügen von {0}' -f $ScriptDir)

        $newPSModulesPath=$currentPSModulePaths + ";$($ScriptDir)\"

        Write-Host ('Neuer PSModulPfad: {0}' -f $newPSModulesPath)

        Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PSModulePath -Value $newPSModulesPath
    }
}

if($Remove) {

    if(!$currentPSModulePaths.Contains($ScriptDir)) {
        Write-Host 'Das aktuelle Skriptverzeichnis wurde nicht in die Variable PSModulePath aufgenommen.'
        Write-Host 'Verwenden Sie Set-PersistentPSModulePath.ps1 -Add, um den Modulpfad hinzuzufügen!' 
        exit 0
    }

    Write-Host ('Pfad zum Entfernen: {0}' -f $ScriptDir)

    if((Request-Choice -Caption 'Möchten Sie den Skriptordner aus der persistenten Liste der PowerShell-Module entfernen?') -eq 0) {
        
        Write-Host ('Entfernen von {0}' -f $ScriptDir)

        $newPSModulesPath=$currentPSModulePaths.Replace(";$($ScriptDir)\","")

        Write-Host ('Aktueller PSModulPfad: {0}' -f $newPSModulesPath)

        Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PSModulePath -Value $newPSModulesPath
    }
}
