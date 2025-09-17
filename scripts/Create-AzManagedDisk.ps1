# Basic Azure parameters
$azTargetTenantID = "<your-tenant-id>"
$azTargetSubscriptionID = "<your-subscription-id>"

# Basic role assignment
$azSignInName = "<your-signin-name>"

# Basic RG parameters
$azTargetResourceGroup = "<your-target-resource-group>"
$azTargetLocation = "<your-target-region>"

# Required parameters for the managed disk
$azLocalDiskImageName = "<your-local-vhd-file.vhd>"
$azLocalDiskPath = "/path/to/image/result/$($azLocalDiskImageName)"
$azManagedDiskName = "<your-managed-disk-resource-name>"
$azManagedDiskOSType = "Linux"
$azManagedDiskSku = "<your-target-disk-sku>"
$azHyperVGen = "V1" # Could swap to V2 if your image is V2

Install-Module -Name Az -Repository PSGallery -Force

Connect-AzAccount -Tenant $azTargetTenantID -SubscriptionId $azTargetSubscriptionID

New-AzRoleAssignment -SignInName $azSignInName -RoleDefinitionName "Data Operator for Managed Disks" -Scope "/subscriptions/$($azTargetSubscriptionID)"

New-AzResourceGroup -Name $azTargetResourceGroup -Location $azTargetLocation

# To use $Zone or #sku, add -Zone or -DiskSKU parameters to the command
Add-AzVhd `
	-ResourceGroupName $azTargetResourceGroup `
	-LocalFilePath $azLocalDiskPath `
	-Location $azTargetLocation `
	-DiskName $azManagedDiskName `
	-DiskSku $azManagedDiskSku `
	-DiskHyperVGeneration $azHyperVGen `
	-DiskOsType $azManagedDiskOSType `
	-OverWrite
