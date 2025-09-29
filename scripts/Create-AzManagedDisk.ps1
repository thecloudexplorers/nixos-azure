<#!
.SYNOPSIS
Upload a local VHD and create an Azure Managed Disk (best‑practice version).

.DESCRIPTION
This script validates prerequisites, signs in to Azure, (optionally) ensures a role assignment,
ensures the target resource group exists, and uploads a local VHD as a Managed Disk using Add-AzVhd.
It uses splatting, idempotent checks, and comment‑based help. Designed for interactive or
non‑interactive use (supports -WhatIf).

.REQUIREMENTS
- PowerShell 7+ recommended
- Az PowerShell modules: Az.Accounts, Az.Resources, Az.Compute
- Network connectivity to Azure Storage/Compute endpoints
- Permissions: typically "Data Operator for Managed Disks" on the target subscription/resource group

.NOTES
Author : Mike Beerman / Andreas Krijnen
Version : 2.0
Updated : 2025-09-26
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
	# ===== Azure context =====
	[Parameter(Mandatory)][string]$TenantId,
	[Parameter(Mandatory)][string]$SubscriptionId,

	# Optional UPN for role assignment (skip if not needed)
	[Parameter()][string]$SignInName,

	# ===== Resource group & location =====
	[Parameter(Mandatory)][string]$ResourceGroupName,
	[Parameter(Mandatory)][string]$Location,

	# ===== Disk/VHD inputs =====
	[Parameter(Mandatory)][ValidateScript({ Test-Path $_ })][string]$VhdPath,
	[Parameter(Mandatory)][ValidatePattern('^[a-zA-Z0-9-_\.]{1,80}$')][string]$ManagedDiskName,
	[Parameter()][ValidateSet('Windows','Linux')][string]$OsType = 'Linux',
	[Parameter()][ValidateSet('Standard_LRS','Premium_LRS','StandardSSD_LRS','Premium_ZRS','StandardSSD_ZRS','UltraSSD_LRS')][string]$DiskSku = 'Standard_LRS',
	[Parameter()][ValidateSet('V1','V2')][string]$HyperVGeneration = 'V1',

	# ===== Behavior toggles =====
	[switch]$Overwrite,
	[switch]$AssignRole, # if provided, ensures Data Operator for Managed Disks
	[switch]$InstallMissingModules, # if provided, installs Az.* modules if missing

	# ===== Minimum Az rollup version (top module) =====
	[Version]$RequiredAzVersion = '14.4.0'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Ensure-AzModules {
	$mods = 'Az.Accounts','Az.Resources','Az.Compute'
	$azRollup = Get-Module -ListAvailable -Name Az | Sort-Object Version -Descending | Select-Object -First 1


	if (-not $azRollup) {
		if (-not $InstallMissingModules) {
			throw 'Az PowerShell rollup not found. Re-run with -InstallMissingModules or install Az.* modules.'
		}
		Write-Host 'Az rollup not found. Installing required Az.* modules for CurrentUser...'
		foreach($m in $mods) {
			if (-not (Get-Module -ListAvailable -Name $m)) {
				Install-Module -Name $m -Scope CurrentUser -Force -ErrorAction Stop
			}
		}
	} 
	elseif ($azRollup.Version -lt $RequiredAzVersion) {
		Write-Host ("Az rollup version {0} < required {1}." -f $azRollup.Version, $RequiredAzVersion)
		if ($InstallMissingModules) {
			Write-Host 'Updating required Az.* modules for CurrentUser...'
			foreach($m in $mods){
				Install-Module -Name $m -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
			}
		} 
		else {
				throw ("Az version {0} is below required {1}. Re-run with -InstallMissingModules or update manually." -f $azRollup.Version, $RequiredAzVersion)
		}
	}

	foreach($m in $mods){ Import-Module $m -ErrorAction Stop }
}

function Ensure-Connected {
	Write-Host "Connecting to Azure (Tenant: $TenantId, Subscription: $SubscriptionId)..."
	# If already logged in, just set context; else prompt/managed identity will handle
	try { 
		$null = Get-AzContext -ErrorAction Stop 
	} 
	catch { }
	$ctx = Get-AzContext -ErrorAction SilentlyContinue
	if (-not $ctx) {
		Connect-AzAccount -Tenant $TenantId | Out-Null
	}
	Set-AzContext -Tenant $TenantId -Subscription $SubscriptionId | Out-Null
}

function Ensure-RoleAssignment {
	if (-not $AssignRole) { return }
	if (-not $SignInName) {  
		throw '-AssignRole was specified but -SignInName is empty.' 
	}
	$scope = "/subscriptions/$SubscriptionId"
	$role = 'Data Operator for Managed Disks'
	# Check existing
	$existing = Get-AzRoleAssignment -SignInName $SignInName -Scope $scope -ErrorAction SilentlyContinue |
	Where-Object { $_.RoleDefinitionName -eq $role }

	if ($existing) {
		Write-Info "Role assignment already present for '$SignInName' -> '$role' at scope $scope."
		return
	}
	if ($PSCmdlet.ShouldProcess("$SignInName","Assign role '$role' at $scope")) {
		Write-Host "Creating role assignment '$role' for '$SignInName' at $scope..."
		$params = @{ 
			SignInName = $SignInName
			RoleDefinitionName = $role
			Scope = $scope
		}
		New-AzRoleAssignment @params | Out-Null
	}
}

function Ensure-ResourceGroup {
	$rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
	if (-not $rg) {
		if ($PSCmdlet.ShouldProcess("ResourceGroup/$ResourceGroupName","Create in $Location")) {
			Write-Host "Creating resource group '$ResourceGroupName' in $Location..."
			New-AzResourceGroup -Name $ResourceGroupName -Location $Location | Out-Null
		}
	} else {
		Write-Host "Resource group '$ResourceGroupName' already exists."
	}
}

function Start-UploadVhd {
	if (-not (Test-Path -Path $VhdPath)) { throw "VHD path not found: $VhdPath" }
	if ([IO.Path]::GetExtension($VhdPath) -ne '.vhd'){
		throw "Only fixed .vhd is supported by Add-AzVhd (not .vhdx). Provided: $VhdPath"
	}

	$addVhdParams = @{
		ResourceGroupName 	= $ResourceGroupName
		LocalFilePath 		= $VhdPath
		Location 			= $Location
		DiskName 			= $ManagedDiskName
		DiskSku 			= $DiskSku
		DiskHyperVGeneration= $HyperVGeneration
		DiskOsType 			= $OsType
	}
	
	if ($PSCmdlet.ShouldProcess($ManagedDiskName, $msg)){
		Write-Host "Upload VHD and create Managed Disk '$ManagedDiskName' in RG '$ResourceGroupName' at $Location"
	if ($Overwrite) {
		Add-AzVhd @addVhdParams -OverWrite
	} else {
		Add-AzVhd @addVhdParams
	}
		Write-Info 'Upload completed.'
	}
}

try {
	Ensure-AzModules
	Ensure-Connected
	Ensure-ResourceGroup
	Ensure-RoleAssignment
	Start-UploadVhd
}
catch {
	Write-Host $_.Exception.Message
	throw
}