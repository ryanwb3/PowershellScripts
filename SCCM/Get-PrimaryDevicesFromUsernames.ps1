<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.175
	 Created on:   	7/17/2020 9:58 AM
	 Created by:   	ryanwb3
	 Organization: 	Public Library of Cincinnati and Hamilton County
	 Filename:     	Get-PrimaryDevicesFromUsernames.ps1
	===========================================================================
	.DESCRIPTION
		Grabs sccm(mecm) primary devices from a list of users. Outputs csv
		
		Validation Scripts taken from:
			https://4sysops.com/archives/validating-file-and-folder-paths-in-powershell-parameters/
#>
[CmdletBinding()]
param (
	[Parameter(Mandatory)]
	[string]$SiteCode,
	[string]$SiteServer,
	[ValidateScript({
			if (-Not ($_ | Test-Path))
			{
				throw "File does not exist"
			}
			if (-Not ($_ | Test-Path -PathType Leaf))
			{
				throw "The Path argument must be a file. Folder paths are not allowed."
			}
			return $true
		})]
	[System.IO.FileInfo]$ImportCSV,
	[string]$Domain,
	[string]$UsernameColumn,
	[ValidateScript({
			if ($_ | Test-Path)
			{
				throw "File already exists"
			}
			if ($_ | Test-Path -PathType Leaf)
			{
				throw "The Path argument must be a file. Folder paths are not allowed."
			}
			if ($_ -notmatch "(\.csv)")
			{
				throw "The file specified in the path argument must be of type csv"
			}
			return $true
		})]
	[System.IO.FileInfo]$ExportCSV
)

#Connect to SCCM(MECM)
# Customizations
$initParams = @{ }
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Import the ConfigurationManager.psd1 module 
if ((Get-Module ConfigurationManager) -eq $null)
{
	Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams
}

# Connect to the site's drive if it is not already present
if ((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null)
{
	New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $SiteServer @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams

#Grabusernames
$staff = import-csv $ImportCSV
#$staff = (Get-ADGroupMember -identity "GROUPNAME" -Recursive | foreach{ get-aduser $_} | select SamAccountName).Samaccountname
$array = @()
foreach ($user in $staff)
{
	$username = $Domain + "\" + $user.$($UsernameColumn)
	[string]$pcs = Get-CMUserDeviceAffinity -UserName $username | ?{ $_.Sources -contains '4' } | %{ Get-CMDevice -fast -ResourceId $_.ResourceID | select -ExpandProperty Name }
	$array += New-Object psobject -Property @{
		PrimaryDevices = $pcs
		Username  = $username
	}
}
$array | export-csv $ExportCSV -NoTypeInformation

